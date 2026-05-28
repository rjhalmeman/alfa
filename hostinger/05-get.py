import os
import time
import tkinter as tk
from tkinter import simpledialog, messagebox
from datetime import datetime
from mss import mss
from mss.tools import to_png
from pynput import keyboard, mouse

# --- CONFIGURAÇÕES DO PROGRAMA ---
SAVE_DIR = os.path.expanduser("~/.sc")
LOG_PATH = os.path.expanduser("~/log.get")
SENHA_ESTATICA = "2025"  # <-- Altere aqui a sua senha secreta

os.makedirs(SAVE_DIR, exist_ok=True)

class App:
    def __init__(self, root):
        self.root = root
        self.root.title("Configurações do Capturador")
        self.root.geometry("300x200")
        
        # Se o usuário clicar no 'X', a janela apenas se esconde
        self.root.protocol("WM_DELETE_WINDOW", self.hide_window) 
        
        # Variável parametrizável do tempo (começa com 10 segundos)
        self.intervalo_var = tk.IntVar(value=10)
        
        # Variáveis de rastreamento de ociosidade
        self.last_activity_time = time.time()
        self.idle_limit_seconds = 10 
        
        # Interface Simples
        tk.Label(root, text="Intervalo de Captura (segundos):").pack(pady=10)
        tk.Entry(root, textvariable=self.intervalo_var).pack()
        
        tk.Button(root, text="Salvar e Ocultar", command=self.hide_window).pack(pady=10)
        tk.Button(root, text="Encerrar Programa", command=self.quit_app, bg="#ff4c4c", fg="white").pack(pady=10)
        
        # Vincula um evento virtual para abrir a janela de forma segura entre threads
        self.root.bind("<<ShowGUI>>", lambda e: self.show_window())
        
        # Controlador do mouse para checar a posição atualizada nas capturas
        self.mouse_controller = mouse.Controller()
        
        # O programa começa totalmente oculto
        self.root.withdraw()
        
        # Inicia os escutadores em segundo plano
        self.start_listeners()
        
        # Inicia o loop de screenshots
        self.take_screenshot()

    def update_activity(self, *args):
        """Atualiza a variável com o tempo exato da última ação do usuário."""
        self.last_activity_time = time.time()

    def start_listeners(self):
        # 1. Escutador do Atalho (Ctrl + Alt + 9)
        def on_activate():
            self.root.event_generate("<<ShowGUI>>", when="tail")

        self.hotkey_listener = keyboard.GlobalHotKeys({'<ctrl>+<alt>+9': on_activate})
        self.hotkey_listener.start()

        # 2. Escutador Geral do Teclado
        self.kb_listener = keyboard.Listener(on_press=self.update_activity)
        self.kb_listener.start()

        # 3. Escutador Geral do Mouse
        self.mouse_listener = mouse.Listener(
            on_move=self.update_activity,
            on_click=self.update_activity,
            on_scroll=self.update_activity
        )
        self.mouse_listener.start()

    def take_screenshot(self):
        current_time = time.time()
        
        # Verifica se o usuário não está ocioso
        if current_time - self.last_activity_time <= self.idle_limit_seconds:
            try:
                # Pega a posição atual do mouse na tela
                mx, my = self.mouse_controller.position
                
                with mss() as sct:
                    # sct.monitors[0] representa todas as telas juntas.
                    # Do índice 1 em diante, temos os monitores individuais.
                    monitor_alvo = sct.monitors[0]  # Fallback caso dê algo errado
                    
                    for monitor in sct.monitors[1:]:
                        # Verifica se o ponteiro do mouse está dentro das coordenadas deste monitor
                        if (monitor["left"] <= mx < monitor["left"] + monitor["width"] and
                            monitor["top"] <= my < monitor["top"] + monitor["height"]):
                            monitor_alvo = monitor
                            break
                    
                    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
                    filepath = os.path.join(SAVE_DIR, f"i_{timestamp}.png")
                    
                    # Captura apenas a região do monitor selecionado
                    sct_img = sct.grab(monitor_alvo)
                    to_png(sct_img.rgb, sct_img.size, output=filepath)
                    
            except Exception as e:
                print(f"Erro ao capturar tela: {e}")
        
        # Próxima execução programada
        interval_ms = self.intervalo_var.get() * 1000
        self.root.after(interval_ms, self.take_screenshot)

    def show_window(self):
        self.root.deiconify() 
        self.root.lift()      
        self.root.attributes('-topmost', True) 
        self.root.after_idle(self.root.attributes, '-topmost', False)

    def hide_window(self):
        self.root.withdraw() 

    def quit_app(self):
        # Solicita a senha para o usuário
        senha_digitada = simpledialog.askstring("Autenticação", "Digite a senha para encerrar o programa:", show="*")
        
        if senha_digitada == SENHA_ESTATICA:
            # Grava o arquivo de log no diretório do usuário
            try:
                with open(LOG_PATH, "a", encoding="utf-8") as log_file:
                    data_hora = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    log_file.write(f"Programa encerrado em: {data_hora}\n")
            except Exception as e:
                print(f"Não foi possível salvar o log: {e}")
            
            self.root.destroy()
            os._exit(0)
        else:
            if senha_digitada is not None: # Se não cancelou a janela
                messagebox.showerror("Erro", "Senha incorreta! O programa continuará executando.")

if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    root.mainloop()