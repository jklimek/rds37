<?php
define ('NL', '<br />');
define ('MAP_DIR', 'maps/');
define ('INDENT', '     ');

build_foyer();


function build_foyer() {
    $map_ = [];
    
    add_map_comment($map_, 'upper left wall');
    for ($i = 1; $i<=20; $i++) {
        add_map_element($map_, "1 $i", 'Uwall');
    }
    
    add_map_comment($map_, 'lower right wall');
    for ($i = 2; $i<=20; $i++) {
        add_map_element($map_, "20 $i", 'Lwall');
    }
    
    add_map_comment($map_, 'upper right wall');
    for ($i = 1; $i<=20; $i++) {
        add_map_element($map_, "$i 1", 'Uwall');
    }
    
    add_map_comment($map_, 'lower left wall');
    for ($i = 2; $i<=20; $i++) {
        add_map_element($map_, "$i 20", 'Lwall');
    }
    
    add_map_comment($map_, 'boss door');
    for ($i=9; $i<=12; $i++) {
        add_map_element($map_, "$i 1", 'Hdoor');
    }
    
    add_map_comment($map_, 'front door');
    for ($i=10; $i<=11; $i++) {
        add_map_element($map_, "$i 20", 'Hdoor');
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