import docx2pdf
import win32com.client
import re
import os
import argparse
from txt2pdf.core import txt2pdf

def excel2pdf(input_file, output_file):
    #エクセルを開く
    app = win32com.client.Dispatch("Excel.Application")
    app.Visible = True
    app.DisplayAlerts = False
    # Excelでワークブックを読み込む
    book = app.Workbooks.Open(input_file)

    for sh in book.Sheets:

        app.Worksheets(sh.Name).Activate()
        ws = app.ActiveSheet
        ws.PageSetup.Orientation = 2 # 横:xlLandscape(2)/縦:xlPortrait(1)
        ws.PageSetup.Zoom = 60

    # PDF形式で保存
    xlTypePDF = 0
    book.ExportAsFixedFormat(xlTypePDF, output_file, 0)
    #エクセルを閉じる
    app.Quit()

if __name__ == '__main__':
    # 対象ディレクトリを入力(コピペok)(最後に\(¥)をつけない)
    # print("Which dir(full path)?:", end="")
    parser = argparse.ArgumentParser()
    parser.add_argument('--file', default=r'C:\Users\shingo.niiyama\git\azure-search-openai-demo-tc\data')
    args = parser.parse_args()
    # 対象フォルダ
    input_dir = (args.file+"\\").replace('/', os.sep)
    filenames = os.listdir(input_dir)
    output_dir = (input_dir).replace('/', os.sep)
    # ディレクトリが存在しない場合、ディレクトリを作成する
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for file in filenames:
        # 拡張子が".docx"のものをpdfに変換
        word_match = re.search("\.docx$", file) 
        if word_match: 
            docx2pdf.convert(input_dir+file, output_dir+file[:-5]+".pdf")
        # 拡張子が".xlsx"のものをpdfに変換
        excel_match = re.search("\.xlsx$", file) 
        if excel_match: 
            excel2pdf(input_dir+file, output_dir+file[:-5]+".pdf")
        md_match = re.search("\.md$", file) 
        if md_match: 
            txt2pdf(md_file_path=input_dir+file, pdf_file_path=output_dir+file[:-3]+".pdf")