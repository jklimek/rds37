<?php
define ('CLASS_DIR', 'builder_classes/');

function autoload($class) {
    include CLASS_DIR . $class . '.php';
}
spl_autoload_register('autoload');

define ('NL', '<br />');
define ('MAP_DIR', '../maps/');
define ('INDENT', "\t");
define ('LOUD', false);

define ('FOYER_LENTGH', 18);
define ('FOYER_WIDTH', 16);

define ('HALLWAY_LENTGH', 64);
define ('HALLWAY_WIDTH', 14);

define ('BOSS_ROOM_LENTGH', 12);
define ('BOSS_ROOM_WIDTH', 12);

define ('UPPER_WALL_TILE_HIGH', 'WALL_U');
define ('UPPER_WALL_TILE_LOW', 'WALL_L');
define ('LOWER_WALL_TILE', 'WALL_LL');
define ('WALL_NAME', 'a wall');
define ('HORIZONTAL_DOOR_TILE_R', 'DOOR_CLOSED_V_R');
define ('HORIZONTAL_DOOR_TILE_L', 'DOOR_CLOSED_V_R');
define ('HORIZONTAL_DOOR_TILE_R_MINI', 'DOOR_CLOSED_V_R_MINI');
define ('HORIZONTAL_DOOR_TILE_L_MINI', 'DOOR_CLOSED_V_R_MINI');
define ('VERTICAL_DOOR_TILE_R_MINI', 'DOOR_CLOSED_V_R');
define ('VERTICAL_DOOR_TILE_L_MINI', 'DOOR_CLOSED_V_L');
define ('DOOR_NAME', 'a door');
define ('WINDOW_TILE', 'WINDOW_V_DARK_3_A');
define ('WINDOW_NAME', 'a window');
define ('TORCH_TILE_1', 'TORCH_1');
define ('TORCH_TILE_2', 'TORCH_2');
define ('TORCH_NAME', 'a torch');

define('FOYER_ID', '0');
define('HALLWAY_ID', '1');
define('BOSS_ROOM_ID', '2');

define('HERO_TILE', 'LUDEK_H_B');

build_foyer();
build_hallway();
build_boss_room();

function build_hallway() {
    $map = "`(".HALLWAY_ID." (\n";
    $map .= build_hallway_constructions(2, ['Uwindow', 'Uwindow']);
    $map .= "\n".INDENT.")\n";
    $map .= build_hallway_floor();
    $map .= "\n".INDENT.";(ile do nastepnego)\n";
    $map .= INDENT."1"
        . "\n)";
    save_to_file('hallway', $map);
}

function build_hallway_constructions($window_distance, $window_tiles_) {
    $map_ = [];
    
//    add_map_comment($map_, 'hero');
//    add_hero($map_, "8 ".(HALLWAY_LENTGH-1), HALLWAY_ID);
    
    add_rectangle_to_map($map_, 1, 1, HALLWAY_WIDTH, HALLWAY_LENTGH, 'hallway',
            UPPER_WALL_TILE_HIGH, HALLWAY_ID);
    
    add_map_comment($map_, 'upper left windows I level');
    $counter = 0;
    for ($i = 3; $i<=HALLWAY_LENTGH-2; $i+=$window_distance) {
        foreach ($window_tiles_ as $key=>$tile_name) {
            add_map_element($map_, "1 ".($i+$key), WINDOW_TILE.($counter%3+1), WINDOW_NAME, HALLWAY_ID);
            $counter++;
        }
        $i += count($window_tiles_); 
    }
    
    add_map_comment($map_, 'door out');
    add_map_element($map_, (HALLWAY_WIDTH/2)." 1", 'DOOR_CLOSED_H_L', DOOR_NAME, 
            HALLWAY_ID, ',(mk-door-collision 2 6 11)');
    add_map_element($map_, (HALLWAY_WIDTH/2+1)." 1", 'DOOR_CLOSED_H_R', DOOR_NAME,
            HALLWAY_ID, ',(mk-door-collision 2 6 11)');
    
    add_map_comment($map_, 'door in');
    add_map_element($map_, (HALLWAY_WIDTH/2)." ".HALLWAY_LENTGH, 'DOOR_OPEN_H_L', DOOR_NAME,
        HALLWAY_ID, ',(mk-door-collision 0 9 2)');
    add_map_element($map_, (HALLWAY_WIDTH/2+1)." ".HALLWAY_LENTGH, 'DOOR_OPEN_H_R', DOOR_NAME,
        HALLWAY_ID, ',(mk-door-collision 0 9 2)');
    
    add_map_comment($map_, 'torch');
    add_map_element($map_, (HALLWAY_WIDTH-4)." ".(HALLWAY_LENTGH-1), 'TORCH_1', TORCH_NAME, HALLWAY_ID,
            '(unquote id-collision)', 'torch-step');

    $map = implode("\n", $map_);
    return $map;
}

function build_hallway_floor_sequence($length, $shift_, $thunder = false) {
    $sequence_map_[] = "\n".INDENT."($length (\n".INDENT.INDENT;
    $light = ($thunder)? '4' : '3';
    for ($i = 2; $i<=HALLWAY_WIDTH-1; $i++) {
        for ($j = 2; $j<=HALLWAY_LENTGH-1; $j++) {
            add_floor_element($sequence_map_, "$i $j", eval_floor_tile_version($light));
        }
    }
    $shadow_builder = new ShadowBuilder(HALLWAY_LENTGH, HALLWAY_WIDTH);
    overlay_shadow($sequence_map_, $shadow_builder->build_pillars(1, 3), [0,0]);
    if (!$thunder) {
        overlay_shadow($sequence_map_, $shadow_builder->build_cloud_layer(1), $shift_);
    }
    
    $sequence_map_[] = "\n".INDENT."))\n";
    
    $sequence_map = implode(' ', $sequence_map_);
    return $sequence_map;
}

function build_hallway_floor() {
    $map_ = ["\n"];
    add_map_comment($map_, 'regular floor');
    $map_[] = "\n".INDENT."(";
    
    for ($i=1; $i<=HALLWAY_LENTGH; $i++) {
        $thunder = (in_array($i, [10, 12, 13, 45, 47]))? true : false;
        $map_[] = build_hallway_floor_sequence(1, [get_horizontal_shift($i), $i] ,$thunder); //1+$i%2
    }
    
    $map_[] = ")\n";
    $map = implode(" ", $map_);
    return $map;
}
function get_horizontal_shift($i) {
//    if ($i%8<4) {
//        return $i%4;
//    }
//    else {
//        return 3-$i%4;
//    }
    return $i%2+1;
}

function overlay_shadow(&$floor_, $shadow_, $shift_) {
    foreach ($shadow_ as $tile_) {
        $x = ($tile_[0] + $shift_[0]) % HALLWAY_WIDTH;
        $y = ($tile_[1] + $shift_[1]) % HALLWAY_LENTGH;
        if (
            isset($floor_[$x.' '.$y]) && strpos($floor_[$x.' '.$y], 'FLOOR_1') === false
                && !in_array([$x, $y],
                        [
                            [HALLWAY_WIDTH-1, HALLWAY_LENTGH-1],
                            [HALLWAY_WIDTH-2, HALLWAY_LENTGH-1],
                            [HALLWAY_WIDTH-3, HALLWAY_LENTGH-1],
                            [HALLWAY_WIDTH-4, HALLWAY_LENTGH-1],
                            [HALLWAY_WIDTH-5, HALLWAY_LENTGH-1],
                            [HALLWAY_WIDTH-6, HALLWAY_LENTGH-1],
                            [HALLWAY_WIDTH-7, HALLWAY_LENTGH-1],
                            [HALLWAY_WIDTH-1, HALLWAY_LENTGH-2],
                            [HALLWAY_WIDTH-2, HALLWAY_LENTGH-2],
                            [HALLWAY_WIDTH-3, HALLWAY_LENTGH-2],
                            [HALLWAY_WIDTH-4, HALLWAY_LENTGH-2],
                            [HALLWAY_WIDTH-5, HALLWAY_LENTGH-2],
                            [HALLWAY_WIDTH-6, HALLWAY_LENTGH-2],
                            [HALLWAY_WIDTH-1, HALLWAY_LENTGH-3],
                            [HALLWAY_WIDTH-2, HALLWAY_LENTGH-3],
                            [HALLWAY_WIDTH-3, HALLWAY_LENTGH-3],
                            [HALLWAY_WIDTH-4, HALLWAY_LENTGH-3],
                            [HALLWAY_WIDTH-5, HALLWAY_LENTGH-3],
                        ]
                    )
        ) {
            add_floor_element($floor_, $x.' '.$y, eval_floor_tile_version($tile_['val']));
        }
    }
}

function build_foyer() {
    $map = "`(".FOYER_ID." (\n";
    $map .= build_foyer_constructions();
    $map .= "\n".INDENT.")\n";
    $map .= build_foyer_floor();
    $map .= "\n".INDENT.";(ile do nastepnego)\n";
    $map .= INDENT."1"
        . "\n)";
    save_to_file('foyer', $map);
}

function build_foyer_floor() {
    $map_ = ["\n"];
    add_map_comment($map_, 'regular floor');
    $map_[] = "\n".INDENT."((3 (\n".INDENT.INDENT;
    
    for ($i = 2; $i<=FOYER_WIDTH-1; $i++) {
        for ($j = 2; $j<=FOYER_LENTGH-1; $j++) {
            add_floor_element($map_, "$i $j", eval_floor_tile_version());
        }
    }
    $map_[] = "\n".INDENT.")))\n";
    
    $map = implode(" ", $map_);
    return $map;
}

function eval_floor_tile_version($light = '3') {
    return 'FLOOR_'.$light;
}

function build_foyer_constructions() {
    $map_ = [];
    
    add_map_comment($map_, 'hero');
    add_hero($map_, "9 ".(FOYER_LENTGH-1), FOYER_ID);
    
    add_rectangle_to_map($map_, 1, 1, FOYER_WIDTH, FOYER_LENTGH, 'foyer', 
        UPPER_WALL_TILE_LOW, FOYER_ID);
    
    add_map_comment($map_, 'boss door');
//    add_map_element($map_, (FOYER_WIDTH/2)." 1", 'DOOR_CLOSED_H_L_MINI', DOOR_NAME, FOYER_ID,
//        ',(mk-door-collision 2 7 7)');
//    add_map_element($map_, (FOYER_WIDTH/2+1)." 1", 'DOOR_CLOSED_H_R_MINI', DOOR_NAME, FOYER_ID,
//        ',(mk-door-collision 2 7 7)');
    add_map_element($map_, (FOYER_WIDTH/2)." 1", 'DOOR_CLOSED_H_L_MINI', DOOR_NAME, FOYER_ID,
        ',(mk-door-collision 1 7 63)');
    add_map_element($map_, (FOYER_WIDTH/2+1)." 1", 'DOOR_CLOSED_H_R_MINI', DOOR_NAME, FOYER_ID,
        ',(mk-door-collision 1 7 63)');
    
    add_map_comment($map_, 'front door');
    add_map_element($map_, (FOYER_WIDTH/2)." ".FOYER_LENTGH, 'DOOR_OPEN_H_L', DOOR_NAME, FOYER_ID);
    add_map_element($map_, (FOYER_WIDTH/2+1)." ".FOYER_LENTGH, 'DOOR_OPEN_H_R', DOOR_NAME, FOYER_ID);
    
    add_map_comment($map_, 'side door');
    add_map_element($map_, '1'." ".(FOYER_LENTGH/2), 'DOOR_CLOSED_V_R', DOOR_NAME, FOYER_ID);
    add_map_element($map_, '1'." ".(FOYER_LENTGH/2+1), 'DOOR_CLOSED_V_L', DOOR_NAME, FOYER_ID);
    
    add_map_comment($map_, 'TORCHES');
    add_map_element($map_, "2 2 ", 'TORCH_1', TORCH_NAME, FOYER_ID,
            '(unquote id-collision)', 'torch-step');
    add_map_element($map_, (FOYER_WIDTH-1)." 2 ", 'TORCH_2', TORCH_NAME, FOYER_ID,
            '(unquote id-collision)', 'torch-step');
    add_map_element($map_, "2 ".(FOYER_LENTGH-1), 'TORCH_1', TORCH_NAME, FOYER_ID,
            '(unquote id-collision)', 'torch-step');
    add_map_element($map_, (FOYER_WIDTH-1)." ".(FOYER_LENTGH-1), 'TORCH_2', TORCH_NAME, FOYER_ID,
            '(unquote id-collision)', 'torch-step');
        
    $map = implode("\n", $map_);
    return $map;
}

function build_boss_room() {
    $map = "`(".BOSS_ROOM_ID." (\n";
    $map .= build_boss_room_constructions();
    $map .= "\n".INDENT.")\n";
    $map .= build_boss_room_floor();
    $map .= "\n".INDENT.";(ile do nastepnego)\n";
    $map .= INDENT."1"
        . "\n)";
    save_to_file('boss', $map);
}

function build_boss_room_constructions() {
    $map_ = [];
    add_rectangle_to_map($map_, 1, 1, BOSS_ROOM_WIDTH, BOSS_ROOM_LENTGH, 'boss room', 
        UPPER_WALL_TILE_LOW, BOSS_ROOM_ID);
    
    add_map_comment($map_, 'door in');
    add_map_element($map_, (BOSS_ROOM_WIDTH/2)." ".BOSS_ROOM_LENTGH, 'DOOR_OPEN_H_L', DOOR_NAME,
        HALLWAY_ID, ',(mk-door-collision 1 7 2)');
    add_map_element($map_, (BOSS_ROOM_WIDTH/2+1)." ".BOSS_ROOM_LENTGH, 'DOOR_OPEN_H_R', DOOR_NAME,
        HALLWAY_ID, ',(mk-door-collision 1 7 2)');
    
    
    add_map_comment($map_, 'TORCHES');
    add_map_element($map_, "2 2 ", 'TORCH_1', TORCH_NAME, BOSS_ROOM_ID,
            '(unquote id-collision)', 'torch-step');
    add_map_element($map_, (BOSS_ROOM_WIDTH-1)." 2 ", 'TORCH_2', TORCH_NAME, BOSS_ROOM_ID,
            '(unquote id-collision)', 'torch-step');
    add_map_element($map_, "2 ".(BOSS_ROOM_LENTGH-1), 'TORCH_1', TORCH_NAME, BOSS_ROOM_ID,
            '(unquote id-collision)', 'torch-step');
    add_map_element($map_, (BOSS_ROOM_WIDTH-1)." ".(BOSS_ROOM_LENTGH-1), 'TORCH_2', TORCH_NAME, BOSS_ROOM_ID,
            '(unquote id-collision)', 'torch-step');
    add_map_element($map_, (BOSS_ROOM_WIDTH-1)." ".(BOSS_ROOM_LENTGH-1), 'TORCH_2', TORCH_NAME, BOSS_ROOM_ID,
            '(unquote id-collision)', 'torch-step');
    add_map_comment($map_, 'altar');
    add_map_element($map_, (BOSS_ROOM_WIDTH/2)." ".(BOSS_ROOM_LENTGH/2), 'ALTAR_L_1', TORCH_NAME, BOSS_ROOM_ID,
            '(unquote id-collision)');
    add_map_element($map_, (BOSS_ROOM_WIDTH/2+1)." ".(BOSS_ROOM_LENTGH/2), 'ALTAR_R_1', TORCH_NAME, BOSS_ROOM_ID,
            '(unquote id-collision)');
    
    $map = implode("\n", $map_);
    return $map;
}

function build_boss_room_floor() {
    $map_ = ["\n"];
    add_map_comment($map_, 'regular floor');
    $map_[] = "\n".INDENT."((3 (\n".INDENT.INDENT;
    
    for ($i = 2; $i<=BOSS_ROOM_WIDTH-1; $i++) {
        for ($j = 2; $j<=BOSS_ROOM_LENTGH-1; $j++) {
            add_floor_element($map_, "$i $j", eval_floor_tile_version());
        }
    }
    $map_[] = "\n".INDENT.")))\n";
    
    $map = implode(" ", $map_);
    return $map;
}

function add_rectangle_to_map(
    &$map_, $start_x, $start_y, $width, $length, $name, $upper_tile, $location_id
) {
    
    add_map_comment($map_, $name. ' upper left wall');
    for ($i = $start_y; $i<$start_y+$length; $i++) {
        add_map_element($map_, "$start_x $i", $upper_tile, WALL_NAME, $location_id);
    }
    
    add_map_comment($map_, $name. ' lower right wall');
    for ($i = $start_y+1; $i<$start_y+$length; $i++) {
        add_map_element($map_, ($start_x + $width - 1)." $i", LOWER_WALL_TILE, WALL_NAME, $location_id);
    }
    
    add_map_comment($map_, $name. ' upper right wall');
    for ($i = $start_x; $i<$start_x+$width; $i++) {
        add_map_element($map_, "$i $start_y", $upper_tile, WALL_NAME, $location_id);
    }
    
    add_map_comment($map_, $name. ' lower left wall');
    for ($i = $start_x+1; $i<$start_x+$width; $i++) {
        add_map_element($map_, "$i ".($start_y + $length - 1), LOWER_WALL_TILE, WALL_NAME, $location_id);
    }
}

function add_hero(&$map_, $coordinates, $location_id) {   
    $map_[] = INDENT."(HERO $location_id "
        . $coordinates
        . " 0 0 (unquote (AL:new '(HEARTRATE NIDERITE) '(70 0))) \"the hero\" ,"
            .HERO_TILE. " (unquote hero-step) (unquote id-collision) (unquote hero-action))";
}

function save_to_file($name, $content) {
    $file = fopen(MAP_DIR.$name.".scm", 'w+');
    fwrite($file, $content);
    fclose($file);
}

function add_map_comment(&$map_, $comment) {
    if (LOUD) {
        echo(';;'.$comment.NL);
    }
    $map_[] = INDENT.';;'.$comment;
}

function add_floor_element(&$map_, $coordinates, $floor_type) {
    if (LOUD){
        echo($coordinates.NL);
    }
//    unset($map_[$coordinates]);
    $map_[$coordinates] = "($coordinates ,$floor_type)";
}

function add_map_element(&$map_, $coordinates, $file_name, $object_type, $location_id,
    $collision = '(unquote id-collision)', $step = 'id-step'
){
    if (LOUD) {
        echo($coordinates.NL);
    }
    unset($map_[$coordinates]);
    $map_[$coordinates] = preg_replace(
        '#([0-9]+) ([0-9]+)#',
        INDENT.'('.$file_name.'\1:\2 '.$location_id.' \1 \2 0 0 () "'.$object_type
            .'" ,'.$file_name." (unquote $step) ".$collision.' (unquote id-action))',
        $coordinates
    );
}