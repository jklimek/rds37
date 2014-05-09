<?php
define ('NL', '<br />');
define ('MAP_DIR', 'maps/');
define ('INDENT', '     ');

define ('FOYER_LENTGH', 18);
define ('FOYER_WIDTH', 16);

build_foyer();
build_foyer_floor();

function build_foyer_floor() {
    $map_ = [];
    add_map_comment($map_, 'regular floor');
    $map_[] = "\n".INDENT.'((3 (';
    
    for ($i = 2; $i<=FOYER_WIDTH-1; $i++) {
        for ($j = 2; $j<=FOYER_LENTGH-1; $j++) {
            add_floor_element($map_, "$i $j", "9");
        }
    }
    $map_[] = INDENT.')))';
    save_to_file('foyer_floor', implode(" ", $map_));
}

function build_foyer() {
    $map_ = [];
    
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
        
    save_to_file('foyer', implode("\n", $map_));
}

function save_to_file($name, $content) {
    $file = fopen(MAP_DIR.$name, 'w+');
    fwrite($file, $content);
    fclose($file);
}

function add_map_comment(&$map_, $comment) {
    echo(';;'.$comment.NL);
    $map_[] = INDENT.';;'.$comment;
}

function add_floor_element(&$map_, $coordinates, $floor_type) {
    echo($coordinates.NL);
    unset($map_[$coordinates]);
    $map_[$coordinates] = "($coordinates $floor_type)";
}

function add_map_element(&$map_, $coordinates, $object_type) {
    echo($coordinates.NL);
    unset($map_[$coordinates]);
    $map_[$coordinates] = preg_replace(
        '#([0-9]+) ([0-9]+)#',
        INDENT.'('.$object_type.'\1:\2 0 \1 \2 0 0 () "'.$object_type
            .'" ,id-step ,id-collision ,id-action)',
        $coordinates
    );
}