Import-Module ActiveDirectory
do {
    # 1) Mostrar el menú
    Write-Host "1. Información del dominio"
    Write-Host "2. Crear OU"
    Write-Host "3. Crear grupo"
    Write-Host "4. Crear usuario"
    Write-Host "5. Salir"

    # 2) Leer la opción
    $opcion = Read-Host "Elige una opción"

    # 3) Según la opción, hacer una cosa u otra
    switch ($opcion) {
"1" { Write-Host "VER INFORMACIÓN DEL EQUIPO Y DOMINIO"
      $equipo = $env:COMPUTERNAME
      $dominio = (Get-ADDomain).DNSRoot
      $numOUs = (Get-ADOrganizationalUnit -Filter *).Count
      $numGrupos = (Get-ADGroup -Filter *).Count
      $numUsuarios = (Get-ADUser -Filter *).Count

        Write-Host "Nombre del equipo: $equipo"
        Write-Host "Dominio: $dominio"
        Write-Host "Número de Grupos: $numGrupos"
        Write-Host "Número de Usuarios: $numUsuarios" 
    }
"2" { Write-Host "CREAR UNIDAD ORGANIZATIVA"

            # Mostrar mensaje para escribir el nombre de la OU
            $nombreOU = Read-Host "Nombre de la nueva OU"

            # Comando para crear una nueva OU
            New-ADOrganizationalUnit -Name $nombreOU

            Write-Host "Unidad Organizativa '$nombreOU' creada correctamente."
            Read-Host "Presiona Enter para volver al menú"
        }
"3" { Write-Host "CREAR GRUPO"

            # Lectura del nombre de grupo y la OU de destino
            $nombreGrupo = Read-Host "Nombre del nuevo grupo"
            $nombreOU = Read-Host "OU donde se creará el grupo"

            # Construcción de la ruta DistinguishedName
            $dominioDN = (Get-ADDomain).DistinguishedName
            $ruta = "OU=$nombreOU,$dominioDN"

            # Creación del grupo con el parámetro -Path correspondiente
            New-ADGroup -Name $nombreGrupo -GroupScope Global -Path $ruta

            Write-Host "Grupo '$nombreGrupo' creado correctamente en '$ruta'."
            Read-Host "`Presiona Enter para volver al menú..."
        }
"4" { Write-Host "CREAR USUARIO Y AÑADIR A GRUPO"

            # Solicitar datos del usuario
                $nombre = Read-Host "Nombre completo"
                $usuario = Read-Host "Nombre de inicio de sesión"
                $ou = Read-Host "OU donde se creará"
                $grupo = Read-Host "Grupo al que se añadirá"

            # Pedir contraseña oculta
                $clave = Read-Host "Contraseña inicial" -AsSecureString

            # Construir la ruta completa DN
                $dominioDN = (Get-ADDomain).DistinguishedName
                $dominio = (Get-ADDomain).DNSRoot
                $ruta = "OU=$ou,$dominioDN"

            # Creación del usuario
                New-ADUser -Name $nombre `
               -SamAccountName $usuario `
               -UserPrincipalName "$usuario@$dominio" `
               -Path $ruta `
               -AccountPassword $clave `
               -Enabled $true `
               -ChangePasswordAtLogon $true
               
    # Integración del usuario en el grupo
    Add-ADGroupMember -Identity $grupo -Members $usuario

    Write-Host "Usuario '$usuario' creado y añadido al grupo '$grupo' con éxito."
    Read-Host "Presiona Enter para volver al menú..." }
"5" { Write-Host "Adiós" 
        default { Write-Host "Opción no válida" }
    }


}} while ($opcion -ne "5")
