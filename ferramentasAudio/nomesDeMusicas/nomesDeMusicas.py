import os
import acoustid
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext
import threading

# CONFIGURAÇÃO
API_KEY = 'SUA_API_KEY_AQUI'  # Obtenha em https://acoustid.org/get-api-key

class MusicIDApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Identificador Automático de Músicas")
        self.root.geometry("700x600")
        
        self.selected_path = tk.StringVar()
        
        # Interface
        tk.Label(root, text="Identificar e Renomear por Áudio", font=("Arial", 16, "bold"), pady=10).pack()

        frame_path = tk.Frame(root, padx=10, pady=10)
        frame_path.pack(fill="x")
        
        tk.Entry(frame_path, textvariable=self.selected_path, state="readonly").pack(side="left", fill="x", expand=True, padx=(0, 5))
        tk.Button(frame_path, text="Selecionar Pasta", command=self.browse_folder).pack(side="right")

        tk.Label(root, text="Log de Identificação:").pack(anchor="w", padx=10)
        self.log_area = scrolledtext.ScrolledText(root, height=20, padx=5, pady=5)
        self.log_area.pack(fill="both", expand=True, padx=10, pady=5)

        self.btn_start = tk.Button(root, text="🔍 IDENTIFICAR E RENOMEAR", bg="#2196F3", fg="white", 
                                  font=("Arial", 10, "bold"), height=2, command=self.start_process_thread)
        self.btn_start.pack(fill="x", padx=10, pady=10)

    def log(self, message):
        self.log_area.insert(tk.END, message + "\n")
        self.log_area.see(tk.END)

    def browse_folder(self):
        folder = filedialog.askdirectory()
        if folder:
            self.selected_path.set(folder)

    def start_process_thread(self):
        if not self.selected_path.get():
            messagebox.showwarning("Aviso", "Selecione uma pasta primeiro!")
            return
        
        if API_KEY == 'SUA_API_KEY_AQUI':
            messagebox.showerror("Erro", "Você precisa configurar sua API KEY do AcoustID no código.")
            return

        # Rodar em thread para não travar a interface
        thread = threading.Thread(target=self.process_files)
        thread.start()

    def identify_audio(self, file_path):
        try:
            # Analisa o áudio e busca no banco de dados AcoustID/MusicBrainz
            results = acoustid.match(API_KEY, file_path, parse=True)
            
            # Pega o primeiro resultado com maior confiança
            for score, recording_id, title, artist in results:
                # Tentando buscar o ano (o AcoustID às vezes não retorna o ano direto, 
                # seria necessário consultar a API do MusicBrainz com o recording_id para precisão total)
                # Por simplificação, usaremos "0000" ou buscaremos metadados extras se disponíveis
                year = "0000" 
                return year, artist, title
                
            return None
        except Exception as e:
            return f"Erro: {str(e)}"

    def process_files(self):
        path = self.selected_path.get()
        files = [f for f in os.listdir(path) if f.lower().endswith(('.mp3', '.wav', '.flac', '.m4a'))]
        
        if not files:
            self.log("Nenhum arquivo de áudio encontrado.")
            return

        self.btn_start.config(state="disabled")
        self.log(f"Iniciando análise de {len(files)} arquivos...\n")

        success_count = 0
        
        for filename in files:
            file_path = os.path.join(path, filename)
            self.log(f"Analisando: {filename}...")
            
            result = self.identify_audio(file_path)
            
            if result and isinstance(result, tuple):
                year, artist, title = result
                
                # Limpar caracteres inválidos para nomes de arquivo
                clean_artist = "".join([c for c in artist if c.isalnum() or c in (' ', '-', '_')]).strip()
                clean_title = "".join([c for c in title if c.isalnum() or c in (' ', '-', '_')]).strip()
                
                extension = os.path.splitext(filename)[1]
                new_name = f"{year}-{clean_artist}-{clean_title}{extension}"
                new_path = os.path.join(path, new_name)
                
                try:
                    if not os.path.exists(new_path):
                        os.rename(file_path, new_path)
                        self.log(f"✅ Sucesso: {new_name}")
                        success_count += 1
                    else:
                        self.log(f"⚠ Pulado: {new_name} já existe.")
                except Exception as e:
                    self.log(f"❌ Erro ao renomear: {e}")
            else:
                self.log(f"❓ Não foi possível identificar: {filename}")

        self.log(f"\n--- FIM ---")
        self.log(f"Processados: {len(files)} | Identificados: {success_count}")
        self.btn_start.config(state="normal")
        messagebox.showinfo("Concluído", f"Processo finalizado!\n{success_count} músicas identificadas.")

if __name__ == "__main__":
    root = tk.Tk()
    app = MusicIDApp(root)
    root.mainloop()