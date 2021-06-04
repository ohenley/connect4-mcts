with connect4; use connect4;

package game_interface is

   type CSharp_Bool is new Boolean with Size => 8;

   procedure reset_game
     with Export,
     Convention => C,
     External_Name => "connect4_reset_game";

   function get_human_color return player_color
     with Export,
     Convention => C,
     External_Name => "connect4_get_human_color";

   function get_slot_state (row : integer; col : integer) return game_state
     with Export,
     Convention => C,
     External_Name => "connect4_get_slot_state";

   procedure keyboard_input (ki : keyboard_state)
     with Export,
     Convention => C,
     External_Name => "connect4_keyboard_input";

   function update_game return csharp_bool
     with Export,
     Convention => C,
     External_Name => "connect4_update_game";

   function get_winner return game_output
     with Export,
     Convention => C,
     External_Name => "connect4_get_winner";

end game_interface;
