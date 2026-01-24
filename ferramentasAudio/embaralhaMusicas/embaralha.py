import os
import random
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext

class ShufflerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Shuffler & Restorer Pro")
        
        self.root.geometry("600x600")
        
        self.selected_path = tk.StringVar()
        
        # --- Interface ---
        header = tk.Label(root, text="Gerenciador de Ordem de Arquivos RDMS", font=("Arial", 16, "bold"), pady=10)
        header.pack()

        # Seleção de Pasta
        frame_path = tk.Frame(root, padx=10, pady=10)
        frame_path.pack(fill="x")
        
        tk.Entry(frame_path, textvariable=self.selected_path, state="readonly").pack(side="left", fill="x", expand=True, padx=(0, 5))
        tk.Button(frame_path, text="Selecionar Pasta", command=self.browse_folder).pack(side="right")

        # Área de Log
        tk.Label(root, text="Log de Operações:").pack(anchor="w", padx=10)
        self.log_area = scrolledtext.ScrolledText(root, height=12, padx=5, pady=5)
        self.log_area.pack(fill="both", expand=True, padx=10, pady=5)

        # Container de Botões
        btn_frame = tk.Frame(root, pady=10)
        btn_frame.pack(fill="x", padx=10)

        # Botão Embaralhar
        self.btn_shuffle = tk.Button(btn_frame, text="🔀 EMBARALHAR (Add NNNN-)", bg="#4CAF50", fg="white", 
                                    font=("Arial", 10, "bold"), height=2, command=lambda: self.confirm_action("shuffle"))
        self.btn_shuffle.pack(side="left", fill="x", expand=True, padx=5)

        # Botão Restaurar
        self.btn_restore = tk.Button(btn_frame, text="⏪ RESTAURAR (Remover 5 chars)", bg="#f44336", fg="white", 
                                    font=("Arial", 10, "bold"), height=2, command=lambda: self.confirm_action("restore"))
        self.btn_restore.pack(side="left", fill="x", expand=True, padx=5)

    def log(self, message):
        self.log_area.insert(tk.END, message + "\n")
        self.log_area.see(tk.END)

    def browse_folder(self):
        folder = filedialog.askdirectory()
        if folder:
            self.selected_path.set(folder)
            self.log(f"Pasta selecionada: {folder}")

    def confirm_action(self, mode):
        path = self.selected_path.get()
        if not path:
            messagebox.showwarning("Aviso", "Por favor, selecione uma pasta primeiro.")
            return

        msg = ("Isso irá embaralhar a ordem dos arquivos adicionando um prefixo." if mode == "shuffle" 
               else "Isso removerá os 5 primeiros caracteres de cada arquivo.")
        
        if messagebox.askyesno("Confirmar", f"{msg}\n\nDeseja continuar?"):
            if mode == "shuffle":
                self.shuffle_files(path)
            else:
                self.restore_files(path)

    def shuffle_files(self, dir_path):
        try:
            files = [f for f in os.listdir(dir_path) if os.path.isfile(os.path.join(dir_path, f))]
            if not files:
                self.log("Nenhum arquivo encontrado.")
                return

            # Embaralha a lista original aleatoriamente
            random.shuffle(files) 
            
            self.log(f"Embaralhando {len(files)} arquivos...")

            count = 0
            for i, filename in enumerate(files):
                # Cria o prefixo 0000-, 0001-, etc.
                new_name = f"{i:04d}-{filename}"
                
                old_p = os.path.join(dir_path, filename)
                new_p = os.path.join(dir_path, new_name)

                if not os.path.exists(new_p):
                    os.rename(old_p, new_p)
                    self.log(f"✓ {filename} -> {new_name}")
                    count += 1
            
            self.log(f"\nSucesso: {count} arquivos reordenados.")
            messagebox.showinfo("Concluído", "Arquivos embaralhados com sucesso!")

        except Exception as e:
            messagebox.showerror("Erro", str(e))

    def restore_files(self, dir_path):
        try:
            files = [f for f in os.listdir(dir_path) if os.path.isfile(os.path.join(dir_path, f))]
            count = 0
            
            self.log("Iniciando restauração de nomes...")
            
            for filename in files:
                # Se o arquivo começa com o padrão NNNN-, removemos os 5 primeiros chars
                if len(filename) > 5:
                    new_name = filename[5:] 
                    
                    old_p = os.path.join(dir_path, filename)
                    new_p = os.path.join(dir_path, new_name)

                    if not os.path.exists(new_p):
                        os.rename(old_p, new_p)
                        self.log(f"↺ {filename} -> {new_name}")
                        count += 1
                    else:
                        self.log(f"⚠ Pulado: {new_name} já existe.")
                else:
                    self.log(f"⚠ Pulado: {filename} é curto demais.")

            self.log(f"\nSucesso: {count} nomes restaurados.")
            messagebox.showinfo("Concluído", "Prefixos removidos!")

        except Exception as e:
            messagebox.showerror("Erro", str(e))

if __name__ == "__main__":
    root = tk.Tk()
    app = ShufflerApp(root)
    root.mainloop()