#!/usr/bin/env python3

from dotenv import load_dotenv

load_dotenv(verbose=True)

import functools
import imaplib
import email
import os

# mail server config
mail_server = os.getenv('GMAIL_SMTP_SERVER')
mail_user = os.getenv('GMAIL_USER')
mail_password = os.getenv('GMAIL_PW')
mail_folder = os.getenv('GMAIL_FOLDER')

# config
download_dir = os.path.join(os.getenv('DOWNLOAD_DIR'), mail_user.split('@')[0])

if not os.path.exists(download_dir):
    try:
        os.mkdir(download_dir)
        print('folder %s created' % download_dir)
    except FileExistsError:
        print('folder %s already exists' % download_dir)


def decode_mime_words(s):
    return ''.join(
        word.decode(encoding or 'utf8')
        for word, encoding in email.header.decode_header(s))


# 連接到郵件伺服器
M = imaplib.IMAP4_SSL(mail_server)
M.login(mail_user, mail_password)
M.select(mail_folder)

# TODO 搜尋主旨，儲存檔名(發信日-)


def dl_bank_mail_attch(num):
    typ, msg_data = M.fetch(num, '(RFC822)')
    email_message = email.message_from_bytes(msg_data[0][1])

    # 獲取郵件主旨
    subject = decode_mime_words(email_message['Subject'])
    print(num.decode(), subject)

    # 是否包含附件
    has_attch = False
    if email_message.get_content_maintype() == 'multipart':
        has_attch = functools.reduce(
            lambda a, b: b or a, (part.get_content_disposition() is not None
                                  for part in email_message.walk()), False)

    if not has_attch: return has_attch

    # 如果主旨符合特定條件
    if '帳單' in subject:
        print('  >', 'Checking attachments of %s' % subject)
        # 下載附件
        for part in email_message.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            if part.get('Content-Disposition') is None:
                continue
            try:
                filename = decode_mime_words(part.get_filename())
            except:
                filename = part.get_filename()
            if filename:
                filepath = os.path.join(download_dir, '%s-%s-%s' % (num.decode(), subject, filename))
                if not os.path.isfile(filepath):
                    with open(filepath, 'wb') as f:
                        f.write(part.get_payload(decode=True))
                        print('  >', 'Downloaded to %s' % filepath)
                else:
                    print('  >', '%s already exists' % filepath)
        M.store(num, '-FLAGS', r'(\Seen)')
        M.store(num, '+X-GM-LABELS', 'bot-saved')

# TODO 移除附件密碼

M.select('bankstmt-paymtslip')
result, data = M.search(None, r'(UNSEEN)')
iter = 0

# 遍歷所有未讀郵件
for num in reversed(data[0].split()):
    if dl_bank_mail_attch(num):
        iter += 1
    if iter < 0:
        print(iter)
        break

# 關閉郵件伺服器連接
M.close()
M.logout()
