// Preenche a data atual por padrão ao carregar
document.addEventListener('DOMContentLoaded', () => {
    const dataInput = document.getElementById('data');
    if (dataInput) {
        dataInput.valueAsDate = new Date();
    }
});

function formatarData(dataISO) {
    if (!dataISO) return '';
    const partes = dataISO.split('-');
    return `${partes[2]}/${partes[1]}/${partes[0]}`;
}

function gerarFichas() {
    const inputData = document.getElementById('data').value;
    const qtdFichas = parseInt(document.getElementById('qtdFichas').value) || 1;
    const textoAlunos = document.getElementById('alunos').value;

    const dataFormatada = formatarData(inputData);
    const listaAlunos = textoAlunos
        .split('\n')
        .map(nome => nome.trim())
        .filter(nome => nome.length > 0);

    if (listaAlunos.length === 0) {
        alert('Por favor, informe ao menos um nome de aluno.');
        return;
    }

    const novaAba = window.open('', '_blank');

    if (!novaAba) {
        alert('Abertura de nova aba bloqueada. Por favor, permita pop-ups no seu navegador.');
        return;
    }

    let html = `
        <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
            <meta charset="UTF-8">
            <title>Fichas de Avaliação</title>
            <style>
                @page {
                    size: A4 portrait;
                    margin: 5mm 8mm;
                }
                body {
                    font-family: Arial, Helvetica, sans-serif;
                    font-size: 12.5px;
                    margin: 0;
                    padding: 0;
                    color: #000;
                }
                .btn-imprimir {
                    position: fixed;
                    top: 15px;
                    right: 15px;
                    padding: 8px 16px;
                    background-color: #28a745;
                    color: white;
                    border: none;
                    border-radius: 4px;
                    font-size: 14px;
                    font-weight: bold;
                    cursor: pointer;
                    box-shadow: 0 2px 6px rgba(0,0,0,0.3);
                    z-index: 9999;
                }
                @media print {
                    .btn-imprimir {
                        display: none !important;
                    }
                }
                .ficha-container {
                    display: block;
                    page-break-inside: avoid;
                }
                table {
                    border-collapse: collapse;
                    width: auto;
                    margin: 0;
                }
                th, td {
                    border: 1px solid #000;
                    padding: 2.5px 6px;
                    vertical-align: middle;
                    font-size: 12.5px;
                }
                .col-desc {
                    white-space: nowrap;
                    text-align: left;
                }
                .col-valor {
                    width: 48px;
                    text-align: center;
                }
                .col-nota {
                    width: 55px;
                    text-align: center;
                }
                .col-avaliador {
                    width: 140px;
                    text-align: center;
                }
                .nome-header {
                    font-weight: bold;
                    font-size: 13.5px;
                }
                .obs {
                    margin-top: 2px;
                    font-weight: bold;
                    font-size: 12px;
                }
                hr.linha-corte {
                    border: none;
                    border-top: 1px dashed #000;
                    margin: 4px 0;
                    width: 100%;
                }
            </style>
        </head>
        <body>
            <button class="btn-imprimir" onclick="window.print()">Imprimir / Salvar PDF</button>
    `;

    let totalFichasGeradas = 0;
    const totalGeral = listaAlunos.length * qtdFichas;

    listaAlunos.forEach(aluno => {
        for (let i = 0; i < qtdFichas; i++) {
            totalFichasGeradas++;
            html += `
                <div class="ficha-container">
                    <table>
                        <thead>
                            <tr>
                                <th class="col-desc nome-header">
                                    ${aluno}:${dataFormatada ? ' &nbsp;&nbsp;|&nbsp;&nbsp; Data: ' + dataFormatada : ''}
                                </th>
                                <th class="col-valor">Valor</th>
                                <th class="col-nota">Nota</th>
                                <th class="col-avaliador">Avaliador</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="col-desc">Identificação da Empresa e apresentação da equipe de trabalho</td>
                                <td class="col-valor" style="font-weight: bold;">0,5</td>
                                <td class="col-nota"></td>
                                <td class="col-avaliador" rowspan="5"></td>
                            </tr>
                            <tr>
                                <td class="col-desc">Descrição das atividades realizadas durante o período de estágio</td>
                                <td class="col-valor" style="font-weight: bold;">0,5</td>
                                <td class="col-nota"></td>
                            </tr>
                            <tr>
                                <td class="col-desc">Relato de experiência positiva ou negativas</td>
                                <td class="col-valor" style="font-weight: bold;">0,5</td>
                                <td class="col-nota"></td>
                            </tr>
                            <tr>
                                <td class="col-desc">Apresentação: clareza, objetividade, organização e comunicação.</td>
                                <td class="col-valor" style="font-weight: bold;">0,5</td>
                                <td class="col-nota"></td>
                            </tr>
                            <tr>
                                <td style="text-align: right; font-weight: bold;">Total</td>
                                <td class="col-valor" style="font-weight: bold;">2,0</td>
                                <td class="col-nota"></td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="obs">OBS:</div>
                </div>
            `;

            if (totalFichasGeradas < totalGeral) {
                html += `<hr class="linha-corte"><br>`;
            }
        }
    });

    html += `
        </body>
        </html>
    `;

    novaAba.document.write(html);
    novaAba.document.close();
}