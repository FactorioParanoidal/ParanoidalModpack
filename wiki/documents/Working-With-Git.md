# Работа с репозиторием с помощью GIT

### Клонирование проекта
Для клонирования проекта нужно иметь в системе установленный GIT и использовать команду
```shell
git clone https://github.com/FactorioParanoidal/ParanoidalModpack
```

### CRLF
Обратите внимание на окончания строк.  
По умолчанию на Unix системах для переноса строки используется LF. На Windows - CRLF.  
Код в репозитории хранится с LF. Соответственно, скачанный с GitHub архив с содержимым репозитория через веб интерфейс будет содержать файлы с LF.    
Однако, если вы (возможно при установке) задали параметр конфигурации GIT `core.autocrlf` в `true`, то **GIT на Windows при клонировании/чекауте конвертирует файл в CRLF**.  
Если у вас на сервере окончания файлов будут различаться с клиентскими, то Factorio выдаст ошибку о несоответствии модов!  

В этом случае необходимо поменять этот параметр:
- Только для текущего репозитория: 
    ```shell
    git config core.autocrlf input
    ```
- Для текущего юзера
    ```shell
    git config --global core.autocrlf input
    ```

И после этого обновить файлы:  
*текущие незакоммиченные изменения будут потеряны*
```shell
git rm --cached -r .
git reset --hard
```