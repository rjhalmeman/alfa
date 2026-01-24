#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <time.h>
#include <sys/stat.h>
#include <unistd.h>

#define MAX_PATH 1024
#define MAX_NAME 512
#define MAX_EXT 32
#define MAX_FILES 10000  // Limite máximo de arquivos para processar

// Estrutura para armazenar informações dos arquivos
typedef struct {
    char old_name[MAX_NAME];
    char extension[MAX_EXT];
    char base_name[MAX_NAME];
} FileInfo;

// Função para verificar se um caminho é um arquivo regular
int is_regular_file(const char *path) {
    struct stat path_stat;
    return (stat(path, &path_stat) == 0 && S_ISREG(path_stat.st_mode));
}

// Função para obter o nome base e extensão de um arquivo
void split_filename(const char *filename, char *base_name, char *extension, 
                    size_t base_size, size_t ext_size) {
    const char *dot = strrchr(filename, '.');
    
    if (!dot || dot == filename) {
        // Sem extensão
        strncpy(base_name, filename, base_size - 1);
        base_name[base_size - 1] = '\0';
        extension[0] = '\0';
    } else {
        // Com extensão
        size_t base_len = dot - filename;
        if (base_len >= base_size) base_len = base_size - 1;
        
        strncpy(base_name, filename, base_len);
        base_name[base_len] = '\0';
        
        strncpy(extension, dot, ext_size - 1);
        extension[ext_size - 1] = '\0';
    }
}

// Função para verificar se um número já foi usado (busca binária)
int is_number_used(int number, int *used_numbers, int count) {
    for (int i = 0; i < count; i++) {
        if (used_numbers[i] == number) {
            return 1;
        }
    }
    return 0;
}

// Função de comparação para qsort
int compare_ints(const void *a, const void *b) {
    return (*(int*)a - *(int*)b);
}

// Função para gerar números aleatórios únicos eficientemente
void generate_unique_numbers(int *numbers, int count) {
    // Preenche array com números de 0 a 9999
    int total_numbers = 10000;
    if (count > total_numbers) {
        printf("Erro: Mais arquivos do que números disponíveis (máximo 10000)\n");
        return;
    }
    
    // Cria um array com todos os números possíveis
    int *all_numbers = malloc(total_numbers * sizeof(int));
    if (!all_numbers) {
        printf("Erro de memória!\n");
        return;
    }
    
    for (int i = 0; i < total_numbers; i++) {
        all_numbers[i] = i;
    }
    
    // Embaralha usando Fisher-Yates
    for (int i = total_numbers - 1; i > 0; i--) {
        int j = rand() % (i + 1);
        int temp = all_numbers[i];
        all_numbers[i] = all_numbers[j];
        all_numbers[j] = temp;
    }
    
    // Pega os primeiros 'count' números
    for (int i = 0; i < count; i++) {
        numbers[i] = all_numbers[i];
    }
    
    free(all_numbers);
}

// Função para embaralhar os arquivos em um diretório
void shuffle_files(const char *dir_path) {
    DIR *dir;
    struct dirent *entry;
    char old_path[MAX_PATH];
    
    // Abre o diretório
    dir = opendir(dir_path);
    if (dir == NULL) {
        printf("Erro: Não foi possível abrir o diretório '%s'\n", dir_path);
        return;
    }
    
    printf("Processando arquivos no diretório: %s\n\n", dir_path);
    
    // Array para armazenar informações dos arquivos
    FileInfo *files = malloc(MAX_FILES * sizeof(FileInfo));
    if (!files) {
        printf("Erro de memória!\n");
        closedir(dir);
        return;
    }
    
    int file_count = 0;
    
    // Coleta informações dos arquivos
    while ((entry = readdir(dir)) != NULL && file_count < MAX_FILES) {
        // Ignora diretórios especiais
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }
        
        // Constrói o caminho completo
        snprintf(old_path, sizeof(old_path), "%s/%s", dir_path, entry->d_name);
        
        // Verifica se é um arquivo regular
        if (!is_regular_file(old_path)) {
            continue;
        }
        
        // Armazena informações do arquivo
        FileInfo *file = &files[file_count];
        
        // Copia nome original
        strncpy(file->old_name, entry->d_name, MAX_NAME - 1);
        file->old_name[MAX_NAME - 1] = '\0';
        
        // Extrai nome base e extensão
        split_filename(entry->d_name, file->base_name, file->extension, 
                      MAX_NAME, MAX_EXT);
        
        file_count++;
    }
    
    closedir(dir);
    
    if (file_count == 0) {
        printf("Nenhum arquivo encontrado no diretório.\n");
        free(files);
        return;
    }
    
    printf("Encontrados %d arquivos.\n\n", file_count);
    
    // Gera números aleatórios únicos
    int *random_numbers = malloc(file_count * sizeof(int));
    if (!random_numbers) {
        printf("Erro de memória!\n");
        free(files);
        return;
    }
    
    generate_unique_numbers(random_numbers, file_count);
    
    // Ordena os números para garantir ordem consistente
    qsort(random_numbers, file_count, sizeof(int), compare_ints);
    
    // Processa cada arquivo
    int renamed_count = 0;
    
    for (int i = 0; i < file_count; i++) {
        char new_filename[MAX_NAME];
        char new_path[MAX_PATH];
        
        // Cria o novo nome do arquivo
        int needed = snprintf(new_filename, sizeof(new_filename), 
                             "%04d-%s%s", random_numbers[i], 
                             files[i].base_name, files[i].extension);
        
        if (needed >= (int)sizeof(new_filename)) {
            printf("Aviso: Nome muito longo para '%s'. Usando nome alternativo.\n", 
                   files[i].old_name);
            
            // Nome alternativo: apenas número + extensão
            snprintf(new_filename, sizeof(new_filename), 
                    "%04d%s", random_numbers[i], files[i].extension);
        }
        
        // Constrói os caminhos
        snprintf(old_path, sizeof(old_path), "%s/%s", dir_path, files[i].old_name);
        snprintf(new_path, sizeof(new_path), "%s/%s", dir_path, new_filename);
        
        // Verifica se o novo nome já existe
        if (access(new_path, F_OK) == 0) {
            printf("Erro: '%s' já existe. Pulando arquivo.\n", new_filename);
            continue;
        }
        
        // Renomeia o arquivo
        if (rename(old_path, new_path) == 0) {
            printf("✓ %s -> %s\n", files[i].old_name, new_filename);
            renamed_count++;
        } else {
            printf("✗ Erro ao renomear: %s\n", files[i].old_name);
        }
    }
    
    // Libera memória
    free(random_numbers);
    free(files);
    
    printf("\nResumo:\n");
    printf("=================================\n");
    printf("Arquivos encontrados:  %d\n", file_count);
    printf("Arquivos renomeados:   %d\n", renamed_count);
    printf("Falhas:                %d\n", file_count - renamed_count);
    printf("=================================\n");
}

// Função para mostrar ajuda
void show_help(const char *program_name) {
    printf("Uso: %s <caminho_da_pasta>\n\n", program_name);
    printf("Descrição:\n");
    printf("  Renomeia arquivos em um diretório adicionando um prefixo numérico.\n\n");
    printf("Exemplo:\n");
    printf("  %s /home/musicas/meuAlbum\n\n", program_name);
    printf("Formato do novo nome:\n");
    printf("  NNNN-nomeOriginal.ext (ex: 0042-musica.mp3)\n\n");
    printf("Características:\n");
    printf("  • Gera números únicos de 0000 a 9999\n");
    printf("  • Mantém nome original e extensão\n");
    printf("  • Evita duplicatas de nomes\n");
    printf("  • Trata nomes muito longos automaticamente\n");
}

int main(int argc, char *argv[]) {
    // Inicializa o gerador de números aleatórios
    srand(time(NULL) ^ getpid());
    
    // Verifica argumentos
    if (argc != 2) {
        show_help(argv[0]);
        return 1;
    }
    
    // Verifica se o usuário pediu ajuda
    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) {
        show_help(argv[0]);
        return 0;
    }
    
    // Verifica se o diretório existe
    DIR *dir = opendir(argv[1]);
    if (dir == NULL) {
        printf("Erro: Diretório '%s' não encontrado ou sem permissão de acesso.\n", argv[1]);
        printf("Use '%s --help' para ajuda.\n", argv[0]);
        return 1;
    }
    closedir(dir);
    
    // Pergunta confirmação ao usuário
    printf("Esta ação renomeará permanentemente os arquivos em:\n");
    printf("  %s\n\n", argv[1]);
    printf("Deseja continuar? (s/N): ");
    
    char response[10];
    if (fgets(response, sizeof(response), stdin) == NULL ||
        (response[0] != 's' && response[0] != 'S')) {
        printf("Operação cancelada pelo usuário.\n");
        return 0;
    }
    
    printf("\n");
    
    // Executa o embaralhamento
    shuffle_files(argv[1]);
    
    return 0;
}
