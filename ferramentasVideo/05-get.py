import os
import time
import tkinter as tk
from datetime import datetime
from mss import mss
from pynput import keyboard, mouse

# --- Configuração Inicial da Pasta ---
# Salvará na pasta "Screenshots_Ocultos" dentro da sua pasta de Imagens
SAVE_DIR = os.path.expanduser("~/.sc")
os.makedirs(SAVE_DIR, exist_ok=True)

class App:
    def __init__(self, root):
        self.root = root
        self.root.title("Configurações do Capturador")
        self.root.geometry("300x200")
        
        # Se o usuário clicar no 'X', a janela apenas se esconde, não fecha o app
        self.root.protocol("WM_DELETE_WINDOW", self.hide_window) 
        
        # Variável parametrizável do tempo (começa com 10 segundos)
        self.intervalo_var = tk.IntVar(value=10)
        
        # Variáveis de rastreamento de ociosidade
        self.last_activity_time = time.time()
        self.idle_limit_seconds = 10 # Só captura se houve ação nos últimos 10s
        
        # Interface Simples
        tk.Label(root, text="Intervalo de Captura (segundos):").pack(pady=10)
        tk.Entry(root, textvariable=self.intervalo_var).pack()
        
        tk.Button(root, text="Salvar e Ocultar", command=self.hide_window).pack(pady=10)
        tk.Button(root, text="Encerrar Programa", command=self.quit_app, bg="#ff4c4c", fg="white").pack(pady=10)
        
        # Vincula um evento virtual para abrir a janela de forma segura entre threads
        self.root.bind("<<ShowGUI>>", lambda e: self.show_window())
        
        # O programa começa totalmente oculto
        self.root.withdraw()
        
        # Inicia os escutadores em segundo plano
        self.start_listeners()
        
        # Inicia o loop infinito de screenshots gerenciado pelo próprio Tkinter
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

        # 2. Escutador Geral do Teclado (registra quando qualquer tecla é pressionada)
        self.kb_listener = keyboard.Listener(on_press=self.update_activity)
        self.kb_listener.start()

        # 3. Escutador Geral do Mouse (registra movimento, cliques e scroll)
        self.mouse_listener = mouse.Listener(
            on_move=self.update_activity,
            on_click=self.update_activity,
            on_scroll=self.update_activity
        )
        self.mouse_listener.start()

    def take_screenshot(self):
        current_time = time.time()
        
        # Verifica se o tempo desde a última atividade é menor ou igual ao limite de inatividade (10s)
        if current_time - self.last_activity_time <= self.idle_limit_seconds:
            try:
                with mss() as sct:
                    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
                    filepath = os.path.join(SAVE_DIR, f"i_{timestamp}.png")
                    sct.shot(output=filepath)
            except Exception as e:
                print(f"Erro ao capturar tela: {e}")
        
        # Converte os segundos informados na interface para milissegundos
        interval_ms = self.intervalo_var.get() * 1000
        # O tkinter agenda a próxima execução dessa mesma função
        self.root.after(interval_ms, self.take_screenshot)

    def show_window(self):
        self.root.deiconify() # Tira do modo oculto
        self.root.lift()      # Traz para a frente das outras janelas
        self.root.attributes('-topmost', True) # Força ficar no topo
        self.root.after_idle(self.root.attributes, '-topmost', False)

    def hide_window(self):
        self.root.withdraw() # Oculta a interface novamente

    def quit_app(self):
        self.root.destroy()
        os._exit(0) # Mata o processo completamente, incluindo threads em segundo plano

if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    root.mainloop()