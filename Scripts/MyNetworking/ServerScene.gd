extends Node


# return data about all active lobbies
func get_lobby_data():
	return {
		"42069": ["UltimateLobbyOfAwesome", 6, 9],
		"42070": ["meh", 0, 2]
	}

# Possible format of lobby data
var lobby_dat = {
	"ID": ["name", "cur_players", "max_players"]
}
