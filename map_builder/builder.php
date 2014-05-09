<?php
define ('NL', '<br />');
define ('MAP_DIR', '../maps/');
define ('INDENT', "\t");
define ('LOUD', false);

define ('FOYER_LENTGH', 18);
define ('FOYER_WIDTH', 16);

define ('HALLWAY_LENTGH', 80);
define ('HALLWAY_WIDTH', 14);

build_foyer();
build_hallway();

function build_hallway() {
    $map = "`(0 (\n";
    $map .= build_hallway_constructions();
    $map .= "\n".INDENT.")\n";
    $map .= build_hallway_floor();
    $map .= "\n".INDENT.";(ile do nastepnego)\n";
    $map .= INDENT."1"
        . "\n)";
    save_to_file('hallway', $map);
}

function build_hallway_constructions() {
    $map_ = [];
    
    add_map_comment($map_, 'hero');
    add_hero($map_, "9 ".(HALLWAY_LENTGH-1));
    
    add_map_comment($map_, 'upper left wall');
    for ($i = 1; $i<=HALLWAY_LENTGH; $i++) {
        add_map_element($map_, "1 $i", 'Uwall');
    }
    
    add_map_comment($map_, 'lower right wall');
    for ($i = 2; $i<=HALLWAY_LENTGH; $i++) {
        add_map_element($map_, HALLWAY_WIDTH." $i", 'Lwall');
    }
    
    add_map_comment($map_, 'upper right wall');
    for ($i = 1; $i<=HALLWAY_WIDTH; $i++) {
        add_map_element($map_, "$i 1", 'Uwall');
    }
    
    add_map_comment($map_, 'lower left wall');
    for ($i = 2; $i<=HALLWAY_WIDTH; $i++) {
        add_map_element($map_, "$i ".HALLWAY_LENTGH, 'Lwall');
    }
    
    $map = implode("\n", $map_);
    return $map;
}

function build_hallway_floor() {
    $map_ = ["\n"];
    add_map_comment($map_, 'regular floor');
    $map_[] = "\n".INDENT."((3 (\n".INDENT.INDENT;
    
    for ($i = 2; $i<=HALLWAY_WIDTH-1; $i++) {
        for ($j = 2; $j<=HALLWAY_LENTGH-1; $j++) {
            add_floor_element($map_, "$i $j", eval_floor_tile_version($i, $j));
        }
    }
    $map_[] = "\n".INDENT.")))\n";
    
    $map = implode(" ", $map_);
    return $map;
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

function eval_floor_tile_version($i, $j) {
    return (($i+$j)%2)? 11: 12;
}

function build_foyer_constructions() {
    $map_ = [];
    
    add_map_comment($map_, 'hero');
    add_hero($map_, "9 ".(FOYER_LENTGH-1));
    
    add_map_comment($map_, 'upper left wall');
    for ($i = 1; $i<=FOYER_LENTGH; $i++) {
        add_map_element($map_, "1 $i", 'Uwall');
    }
    
    add_map_comment($map_, 'lower right wall');
    for ($i = 2; $i<=FOYER_LENTGH; $i++) {
        add_map_element($map_, FOYER_WIDTH." $i", 'Lwall');
    }
    
    add_map_comment($map_, 'upper right wall');
    for ($i = 1; $i<=FOYER_WIDTH; $i++) {
        add_map_element($map_, "$i 1", 'Uwall');
    }
    
    add_map_comment($map_, 'lower left wall');
    for ($i = 2; $i<=FOYER_WIDTH; $i++) {
        add_map_element($map_, "$i ".FOYER_LENTGH, 'Lwall');
    }
    
    add_map_comment($map_, 'boss door');
    for ($i=intval(FOYER_WIDTH/2)-1; $i<=intval(FOYER_WIDTH/2)+2; $i++) {
        add_map_element($map_, "$i 1", 'Hdoor');
    }
    
    add_map_comment($map_, 'front door');
    for ($i=intval(FOYER_WIDTH/2); $i<=intval(FOYER_WIDTH/2)+1; $i++) {
        add_map_element($map_, "$i ".FOYER_LENTGH, 'Hdoor');
    }
    
    add_map_comment($map_, 'stairs');
    for ($i=2; $i<=3; $i++) {
        for ($j=2; $j<=6; $j++) {
            add_map_element($map_, "$i $j", 'stair-wall');
        }
    }
    add_map_element($map_, "2 7", 'stair3');
    add_map_element($map_, "3 7", 'stair3');
    add_map_element($map_, "2 8", 'stair2');
    add_map_element($map_, "3 8", 'stair2');
    add_map_element($map_, "2 9", 'stair1');
    add_map_element($map_, "3 9", 'stair1');
        
    $map = implode("\n", $map_);
    return $map;
}

function add_hero(&$map_, $coordinates) {
    $map_[] = INDENT."(HERO 0 "
        . $coordinates
        . " 0 0 (,(cons 'NIDERITE 0)) \"the hero\" ,hero-step ,id-collision ,hero-action)";
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
    unset($map_[$coordinates]);
    $map_[$coordinates] = "($coordinates $floor_type)";
}

function add_map_element(&$map_, $coordinates, $object_type) {
    if (LOUD) {
        echo($coordinates.NL);
    }
    unset($map_[$coordinates]);
    $map_[$coordinates] = preg_replace(
        '#([0-9]+) ([0-9]+)#',
        INDENT.'('.$object_type.'\1:\2 0 \1 \2 0 0 () "'.$object_type
            .'" ,id-step ,id-collision ,id-action)',
        $coordinates
    );
}