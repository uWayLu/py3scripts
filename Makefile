init:
	pip install -r requirements.txt

test:
	python tests/test-imap.py

.PHONY: init test
