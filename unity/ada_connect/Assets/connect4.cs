using System.Collections;
using UnityEngine;
using System.Runtime.InteropServices;
using System.Linq;

public class connect4 : MonoBehaviour
{
    [DllImport("connect4")]
    private static extern void connect4_reset_game();

    [DllImport("connect4")]
    private static extern byte connect4_get_human_color();

    [DllImport("connect4")]
    private static extern byte connect4_get_slot_state(int row, int col);

    [DllImport("connect4")]
    private static extern void connect4_keyboard_input(byte ki);

    [DllImport("connect4")]
    private static extern bool connect4_update_game();

    [DllImport("connect4")]
    private static extern game_output connect4_get_winner();

    enum game_state { x, o, empty }

    enum game_output { x, o, empty, draw }

    enum player_color { x, o }

    public GameObject board;
    public GameObject slot_prefab;
    public GameObject win_text;

    int num_row = 6;
    int num_col = 7;
    player_color human_color;

    void generate_slots()
    {
        float get_anchored_delta_pos(int index, float element_size, float board_size, float padding_percent, int number_slots)
        {
            float padding = board_size * padding_percent;
            float slot_distance = (board_size - padding) / number_slots;
            float pos = index * slot_distance;
            float result = pos - (element_size / 2) + (padding / 2) - (slot_distance - element_size) / 2;
            return result;
        }

        RectTransform board_rt = board.GetComponent<RectTransform>();

        foreach (int row in Enumerable.Range(1, num_row))
        {
            foreach (int col in Enumerable.Range(1, num_col))
            {
                var slot = Instantiate(slot_prefab, new Vector3(0, 0, 0), Quaternion.identity, board.transform);
                slot.name = row + "," + col;

                RectTransform rt = slot.GetComponent<RectTransform>();
                float x = get_anchored_delta_pos(col, rt.sizeDelta.x, board_rt.sizeDelta.x, 0.05f, num_col);
                float y = get_anchored_delta_pos(row, rt.sizeDelta.y, board_rt.sizeDelta.y, 0.05f, num_row);
                rt.anchoredPosition = new Vector2(x, -y);
            }
        }
    }


    void set_slot_state(int row, int col, game_state ss)
    {
        Transform slot = board.transform.Find(row + "," + col);
        Transform red = slot.transform.Find("x");
        Transform yellow = slot.transform.Find("o");

        switch (ss)
        {
            case game_state.x:
                red.gameObject.SetActive(true);
                yellow.gameObject.SetActive(false);
                break;
            case game_state.o:
                red.gameObject.SetActive(false);
                yellow.gameObject.SetActive(true);
                break;
            default:
                red.gameObject.SetActive(false);
                yellow.gameObject.SetActive(false);
                break;
        }
    }

    void update_slots()
    {
        foreach (int row in Enumerable.Range(1, num_row))
        {
            foreach (int col in Enumerable.Range(1, num_col))
            {
                game_state gs = (game_state)connect4_get_slot_state(row, col);
                set_slot_state(row, col, gs);
            }
        }
    }

    byte get_keyboard_input()
    {
        if (Input.GetKeyUp(KeyCode.Alpha1))
        {
            return 1;
        }
        else if (Input.GetKeyUp(KeyCode.Alpha2))
        {
            return 2;
        }
        else if (Input.GetKeyUp(KeyCode.Alpha3))
        {
            return 3;
        }
        else if (Input.GetKeyUp(KeyCode.Alpha4))
        {
            return 4;
        }
        else if (Input.GetKeyUp(KeyCode.Alpha5))
        {
            return 5;
        }
        else if (Input.GetKeyUp(KeyCode.Alpha6))
        {
            return 6;
        }
        else if (Input.GetKeyUp(KeyCode.Alpha7))
        {
            return 7;
        }

        return 8;
    }

    void reset_game()
    {
        win_text.SetActive(false);
        connect4_reset_game();
        human_color = (player_color)connect4_get_human_color();
    }

    void Start()
    {
        reset_game();
        generate_slots();
    }

    bool coroutine_started = false;

    void Update()
    {
        connect4_keyboard_input(get_keyboard_input());
        bool result = connect4_update_game();
        update_slots();
        game_output winner = connect4_get_winner();
        if (winner != game_output.empty && !coroutine_started)
        {
            StartCoroutine(show_winner(winner));
        }     
    }

    IEnumerator show_winner(game_output winner)
    {
        coroutine_started = true;
        string text = "DRAW!";

        if(winner == (game_output)human_color)
        {
            text = "Human WINS!!!";
        }
        else if (winner != game_output.draw)
        {
            text = "Ai WINS!!!";
        }

        win_text.GetComponent<UnityEngine.UI.Text>().text = text;
        win_text.SetActive(true);
        yield return new WaitForSeconds(3);
        reset_game();
        update_slots();
        coroutine_started = false;
    }
}