#!/usr/bin/bash
WORKDIR=$1

cd $WORKDIR

# Remove non-Pdf files
echo $(ls *.* | grep -iv '.pdf')
read -p "Remove non-PDF files? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ [[Yy]$ ]]; then
    ls *.* | grep -iv '.pdf' | xargs -I {} rm "{}"
fi

tree -C -L 1 $1 | less

# Rename Pdfs
rename_pdfs() {
    alias perl-rename='perl-rename'
    perl-rename 's/\.PDF$/.pdf/' *.PDF
    perl-rename 's/台北富邦銀行$/富邦銀行/' *.PDF

    # 信用卡
    perl-rename 's/\d+-(\S+)銀行.*信用卡.*(\d{4})年(\d+)月.*/sprintf "%d%02d-%s銀行-信用卡帳單.pdf", $2, $3, $1/e' *.pdf
    ## 玉山
    perl-rename 's/\d+-(\S+)銀行.*(\d{4})年(\d+)月.*/sprintf "%d%02d-%s銀行-信用卡帳單.pdf", $2, $3, $1/e' *.pdf
    ## 台新
    perl-rename 's/\d+-(\S+).*信用卡.*(\d{4})年(\d+)月.*/sprintf "%d%02d-%s銀行-信用卡帳單.pdf", $2, $3, $1/e' *.pdf
    ## 兆豐
    perl-rename 's/\d+-(\S+).*_信用卡.*帳單.*_(\d{3})(\d{2}).pdf/sprintf "%d%02d-%s-信用卡帳單.pdf", $2+1911, $3, $1/e' *.pdf
    ## 中信
    perl-rename 's/\d+-(\S+).*信用卡.*帳單.*_(\d{3})(\d{2}).pdf/sprintf "%d%02d-%s銀行-信用卡帳單.pdf", $2+1911, $3, $1/e' *.pdf
    #!/usr/bin/bash
    # 對帳單
    perl-rename 's/\d+-New.*(\d{3})\s*年(\d+)\s*月.*對帳單.*/sprintf "%d%02d-聯邦銀行-對帳單.pdf", $1+1911, $2/e' *.pdf
    perl-rename 's/.*(\S{6})銀行.*對帳單.*(\d{4})年(\d+)月.*/sprintf "%d%02d-%s銀行-對帳單.pdf", $2, $3, $1/e' *.pdf
    perl-rename 's/.*(\S{6})銀行.*(\d{4})年(\d+)月.*對帳單.*/sprintf "%d%02d-%s銀行-對帳單.pdf", $2, $3, $1/e' *.pdf
    ## 一銀
    perl-rename 's/\d+-(\S+)\s*(\d{3})\s*年\s*(\d+)\s*月.*對帳單.*/sprintf "%d%02d-%s-對帳單.pdf", $2+1911, $3, $1/e' *.pdf
    ## 中信
    perl-rename 's/\d+-(\S+)銀行.*對帳單.*_(\d{3})(\d{2}).pdf/sprintf "%d%02d-%s銀行-對帳單.pdf", $2+1911, $3, $1/e' *.pdf
    ## 國泰世華, no date
    perl-rename 'our $i; s/\d+-【(\S+)】.*對帳單.pdf/sprintf "%d%02d-%s-對帳單.pdf", 2023, ++$i+12, $1/e' *.pdf
}

read -p "Rename all downloads file? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ [[Yy]$ ]]; then
    rename_pdfs
else
    echo "Filename no changes. "
fi

# Remove pw
if [[ $REPLY =~ [[Yy]$ ]]; then
    ls *.pdf | xargs -I {} pdftk {} input_pw $PDF_PW output {}_rmpw.pdf
    echo "Default PW removed."
else
    echo "Keep PW."
fi
