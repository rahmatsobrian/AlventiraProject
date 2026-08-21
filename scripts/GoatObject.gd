extends Node2D
class_name GoatObject
## Objek dunia untuk side quest "Kambing yang Hilang". Saat diinteraksi,
## menyalakan flag "found_goat" lalu menghilang dari peta — pemain kemudian
## kembali ke Doni untuk menyelesaikan quest (lihat NPC.gd).

signal found

var already_found := false

func interact() -> void:
	if already_found:
		return
	already_found = true
	GameManager.set_flag("found_goat", true)
	print("[INFO] Kambing Belang ditemukan.")
	found.emit()
	queue_free()
