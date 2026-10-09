@echo off
rem Start MavDine Manager: installs what it needs, then opens http://127.0.0.1:5000
cd /d "%~dp0"
python -m pip install -q -r requirements.txt
python app.py
pause
