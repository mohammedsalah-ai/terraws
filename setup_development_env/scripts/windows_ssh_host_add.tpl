add-content -path C:\Users\msal7\.ssh\config -value @'

Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentityFile ${idfile}
'@