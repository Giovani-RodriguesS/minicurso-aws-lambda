
# baixa pipx
sudo apt update
sudo apt install pipx
pipx ensurepath

# instala sam cli via pipx
pipx install aws-sam-cli

# verifica instalação
sam --version

# CASO DE ERRO, TENTAR RODAR:
# nano ~/.bashrc
# export PATH="$HOME/.local/bin:$PATH" - isso no final de seu .bashrc
# source ~/.bashrc
# sam --version