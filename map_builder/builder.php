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

define ('UPPER_WALL_TILE', 'WALL_U');
define ('LOWER_WALL_TILE', 'FLOOR_3');
define ('WALL_NAME', 'a wall');
define ('HORIZONTAL_DOOR_TILE_R', 'DOOR_CLOSED_V_R');
define ('HORIZONTAL_DOOR_TILE_L', 'DOOR_CLOSED_V_R');
define ('DOOR_NAME', 'a door');
define ('WINDOW_TILE', 'WINDOW_V_DARK_3');
define ('WINDOW_NAME', 'a window');

build_foyer();
build_hallway();

function build_hallway() {
    $map = "`(0 (\n";
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
    
    add_map_comment($map_, 'hero');
    add_hero($map_, "8 ".(HALLWAY_LENTGH-1));
    
    add_rectangle_to_map($map_, 1, 1, HALLWAY_WIDTH, HALLWAY_LENTGH, 'hallway');
    
    add_map_comment($map_, 'upper left windows I level');
    for ($i = 3; $i<=HALLWAY_LENTGH-2; $i+=$window_distance) {
        foreach ($window_tiles_ as $key=>$tile_name) {
            add_map_element($map_, "1 ".($i+$key), WINDOW_TILE, WINDOW_NAME);
        }
        $i += count($window_tiles_); 
    }
    
    add_map_comment($map_, 'door in');
    add_map_element($map_, (HALLWAY_WIDTH/2)." 1", HORIZONTAL_DOOR_TILE_L, DOOR_NAME);
    add_map_element($map_, (HALLWAY_WIDTH/2+1)." 1", HORIZONTAL_DOOR_TILE_R, DOOR_NAME);
    
    add_map_comment($map_, 'door out');
    add_map_element($map_, (HALLWAY_WIDTH/2)." ".HALLWAY_LENTGH, HORIZONTAL_DOOR_TILE_L, DOOR_NAME);
    add_map_element($map_, (HALLWAY_WIDTH/2+1)." ".HALLWAY_LENTGH, HORIZONTAL_DOOR_TILE_R, DOOR_NAME);
    
    $map = implode("\n", $map_);
    return $map;
}

function build_hallway_floor_sequence($length, $shift_) {
    $sequence_map_[] = "\n".INDENT."($length (\n".INDENT.INDENT;
    
    for ($i = 2; $i<=HALLWAY_WIDTH-1; $i++) {
        for ($j = 2; $j<=HALLWAY_LENTGH-1; $j++) {
            add_floor_element($sequence_map_, "$i $j", eval_floor_tile_version($i, $j));
        }
    }
    $shadow_builder = new ShadowBuilder(HALLWAY_LENTGH, HALLWAY_WIDTH);
    overlay_shadow($sequence_map_, $shadow_builder->build_pillars(1, 2), [0,0]);
    overlay_shadow($sequence_map_, $shadow_builder->build_cloud_layer(1), $shift_);
    
    $sequence_map_[] = "\n".INDENT."))\n";
    
    $sequence_map = implode(' ', $sequence_map_);
    return $sequence_map;
}

function build_hallway_floor() {
    $map_ = ["\n"];
    add_map_comment($map_, 'regular floor');
    $map_[] = "\n".INDENT."(";
    
    for ($i=1; $i<=HALLWAY_LENTGH; $i++) {
        $map_[] = build_hallway_floor_sequence(1, [1, $i]); //1+$i%2
    }
    
    $map_[] = ")\n";
    $map = implode(" ", $map_);
    return $map;
}

function overlay_shadow(&$floor_, $shadow_, $shift_) {
    foreach ($shadow_ as $tile_) {
        $x = ($tile_[0] + $shift_[0]) % HALLWAY_WIDTH;
        $y = ($tile_[1] + $shift_[1]) % HALLWAY_LENTGH;
        if (isset($floor_[$x.' '.$y])) {
            add_floor_element($floor_, $x.' '.$y, eval_floor_tile_version($x, $y, $tile_['val']));
        }
    }
}

function build_foyer() {
    $map = "`(0 (\n";
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
            add_floor_element($map_, "$i $j", eval_floor_tile_version($i, $j));
        }
    }
    $map_[] = "\n".INDENT.")))\n";
    
    $map = implode(" ", $map_);
    return $map;
}

function eval_floor_tile_version($i, $j, $light = '3') {
    $step = (($i+$j)%2)? 1: 2;
    return 10 + 2 * ($light - 1) + $step;
}

function build_foyer_constructions() {
    $map_ = [];
    
    add_map_comment($map_, 'hero');
    add_hero($map_, "9 ".(FOYER_LENTGH-1));
    
    add_rectangle_to_map($map_, 1, 1, FOYER_WIDTH, FOYER_LENTGH, 'foyer');
    
    add_map_comment($map_, 'boss door');
    add_map_element($map_, (FOYER_WIDTH/2)." 1", HORIZONTAL_DOOR_TILE_L, DOOR_NAME);
    add_map_element($map_, (FOYER_WIDTH/2+1)." 1", HORIZONTAL_DOOR_TILE_R, DOOR_NAME);
//    add_map_element($map_, "$i 1", HORIZONTAL_DOOR_TILE, DOOR_NAME);
//    for ($i=intval(FOYER_WIDTH/2); $i<=intval(FOYER_WIDTH/2)+1; $i++) {
//        add_map_element($map_, "$i 1", HORIZONTAL_DOOR_TILE, DOOR_NAME);
//    }
    
    add_map_comment($map_, 'front door');
    add_map_element($map_, (FOYER_WIDTH/2)." ".FOYER_LENTGH, HORIZONTAL_DOOR_TILE_L, DOOR_NAME);
    add_map_element($map_, (FOYER_WIDTH/2+1)." ".FOYER_LENTGH, HORIZONTAL_DOOR_TILE_R, DOOR_NAME);
//    for ($i=intval(FOYER_WIDTH/2); $i<=intval(FOYER_WIDTH/2)+1; $i++) {
//        add_map_element($map_, "$i ".FOYER_LENTGH, HORIZONTAL_DOOR_TILE, DOOR_NAME);
//    }
    
//    add_map_comment($map_, 'stairs');
//    for ($i=2; $i<=3; $i++) {
//        for ($j=2; $j<=6; $j++) {
//            add_map_element($map_, "$i $j", 'stair-wall');
//        }
//    }
//    add_map_element($map_, "2 7", 'stair3');
//    add_map_element($map_, "3 7", 'stair3');
//    add_map_element($map_, "2 8", 'stair2');
//    add_map_element($map_, "3 8", 'stair2');
//    add_map_element($map_, "2 9", 'stair1');
//    add_map_element($map_, "3 9", 'stair1');
        
    $map = implode("\n", $map_);
    return $map;
}

function add_rectangle_to_map(
    &$map_, $start_x, $start_y, $width, $length, $name
) {
    
    add_map_comment($map_, $name. ' upper left wall');
    for ($i = $start_y; $i<$start_y+$length; $i++) {
        add_map_element($map_, "$start_x $i", UPPER_WALL_TILE, WALL_NAME);
    }
    
    add_map_comment($map_, $name. ' lower right wall');
    for ($i = $start_y+1; $i<$start_y+$length; $i++) {
        add_map_element($map_, ($start_x + $width - 1)." $i", LOWER_WALL_TILE, WALL_NAME);
    }
    
    add_map_comment($map_, $name. ' upper right wall');
    for ($i = $start_x; $i<$start_x+$width; $i++) {
        add_map_element($map_, "$i $start_y", UPPER_WALL_TILE, WALL_NAME);
    }
    
    add_map_comment($map_, $name. ' lower left wall');
    for ($i = $start_x+1; $i<$start_x+$width; $i++) {
        add_map_element($map_, "$i ".($start_y + $length - 1), LOWER_WALL_TILE, WALL_NAME);
    }
}

function add_hero(&$map_, $coordinates) {
    $map_[] = INDENT."(HERO 0 "
        . $coordinates
        . " 0 0 ((unquote (cons (quote NIDERITE) 0))) \"the hero\" 0 (unquote hero-step) "
            . "(unquote id-collision) (unquote hero-action)) ;; !";
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
    $map_[$coordinates] = "($coordinates $floor_type)";
}

function add_map_element(&$map_, $coordinates, $file_name, $object_type) {
    if (LOUD) {
        echo($coordinates.NL);
    }
    unset($map_[$coordinates]);
    $map_[$coordinates] = preg_replace(
        '#([0-9]+) ([0-9]+)#',
        INDENT.'('.$file_name.'\1:\2 0 \1 \2 0 0 () "'.$object_type
            .'" '.$file_name.' (unquote id-step) (unquote id-collision) (unquote id-action))',
        $coordinates
    );
}