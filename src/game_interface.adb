with ada.numerics.discrete_random;

package body game_interface is

   procedure reset_game is
   begin
      game_ss := (others => (others => empty));

      case game_out is
      when x =>
         human_color := o;
      when o =>
         human_color := x;
      when others =>
         declare
            package rand_color is new ada.numerics.discrete_random(player_color);
            use rand_color;
            gen : generator;
         begin
            reset(gen);
            human_color := random(gen);
         end;
      end case;

      winner := empty;
   end;

   function get_human_color return player_color is
   begin
      return human_color;
   exception
      when others =>
         return x;
   end;

   function get_slot_state (row : integer; col : integer) return game_state is
   begin
      return game_ss (row, col);
   exception
      when others =>
         return empty;
   end;

   procedure keyboard_input (ki : keyboard_state) is
   begin
      kbd_state := ki;
   end;

   function update_game return csharp_bool is
   begin
      update;
      return true;
   exception
      when others =>
         return false;
   end;

   function get_winner return game_output is
   begin
      return winner;
   end;


end game_interface;
