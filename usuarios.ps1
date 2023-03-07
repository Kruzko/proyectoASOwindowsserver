import-module activedirectory

#seleccionar que hacer
function menu {
write-host "selecciona que quieres hacer:"
write-host "1.Crear usuario"
write-host "2.Eliminar usuario"
write-host "3.Ver usuarios"
write-host "4.Modificar apellido usuario"
write-host "5.exportar fichero ldif"
write-host "6.importar fichero ldif"
write-host "7.crear varios usuarios"
write-host "8.eliminar varios usuarios"
write-host "9.salir"
}
menu
#while para seleccionar que hacer

while (($inp =read-host -promp "selecciona una opcion") -ne "9"){
	#estos dc1 y dc2 indican el dominio al que pertenece la maquina
$DC1="ies"
$DC2="local"
#este csv sirve para importar nuestro archivo usuarios.csv
$csv = Import-Csv "C:\Users\Administrador\Downloads\proyectolibre\usuarios.csv"
switch($inp){
	1{#este parrafo crea un usuario pidiendo el nombre al usuario y poniendo una contraseña por defecto
	$nombre=read-host -promp "nombre de usuario"
	new-aduser "$nombre" -path "OU=usuarios, DC=$DC1, DC=$DC2" -samaccountname $nombre
	set-adaccountpassword $nombre -newpassword (convertto-securestring -asplaintext "P@ssw0rd" -force)
	set-aduser $nombre -changepasswordatlogon $True
	enable-adaccount $nombre
	write-host "la contraseña por defecto es P@ssw0rd al entrar tendra que cambiarla"
	}
	2{#este parrafo elimina un usuario
	$eliminar=read-host -promp "nombre de usuario a eliminar"
	remove-aduser $eliminar
	}
	3{#este parrafo sirve para ver que usuarios hay creados
	get-aduser -filter * -searchbase "OU=usuarios, DC=$DC1, DC=$DC2"
	}
	4{#este parrafo sirve para añadir o modificar el apellido del usuario
	$modificar=read-host -promp "usuario para poner apellido"
	$apellido=read-host -promp "diga el apellido"
	set-aduser $modificar -surname $apellido
	}
	5{#exportar fichero ldif
	ldifde -r "objectClass=User" -f usuarios.ldif
	}
	6{#importar fichero ldif
	ldifde -i -f prueba.ldif
	}
	7{#en este parrafo metemos usuarios los activamos y les ponemos contraseña a partir del archivo usuarios.csv
		foreach($LINE in $CSV)
		{
		new-aduser "$($LINE.nombre)" -path "OU=usuarios, DC=$DC1, DC=$DC2" -samaccountname $($LINE.nombre)
		set-adaccountpassword $($LINE.nombre) -newpassword (convertto-securestring -asplaintext $($LINE.clave) -force)
		set-aduser $($LINE.nombre) -changepasswordatlogon $True
		enable-adaccount $($LINE.nombre)
		}
		write-host "la clave por defecto es P@ssw0rd al entrar tendra que cambiarla"
	}
	8{#en este parrafo quitamos usuarios fijandonos en el csv concretamente en el campo nombre
		foreach($LINE in $CSV)
		{
			remove-aduser $($LINE.nombre) -Confirm:$false
		}
		write-host "usuarios eliminados"
	}
	9{"exit"; break}
	default {write-host -foregroundcolor red -backgroundcolor white "opcion invalida. por favor inserte otra opcion";pause}
}
menu
}