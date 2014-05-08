<?php
define ('NL', '<br />');
define ('MAP_DIR', 'maps/');
define ('INDENT', '     ');

build_foyer();


function build_foyer() {
    $map = '';
    
    add_lisp_comment('upper left wall', $map);
    for ($i = 1; $i<=20; $i++) {
        add_map_line($map, "1 $i", 'Uwall');
    }
    
    add_lisp_comment('lower right wall', $map);
    for ($i = 1; $i<=20; $i++) {
        add_map_line($map, "20 $i", 'Lwall');
    }
    
    add_lisp_comment('upper right wall', $map);
    for ($i = 1; $i<=20; $i++) {
        if ($i <= 12 & $i >= 9) {
            add_map_line($map, "$i 1", 'Hdoor');
        }
        else{
            add_map_line($map, "$i 1", 'Uwall');
        }
    }
    
    add_lisp_comment('lower left wall', $map);
    for ($i = 1; $i<=20; $i++) {
        if ($i <= 11 & $i >= 10) {
            add_map_line($map, "$i 20", 'Hdoor');
        }
        else{
            add_map_line($map, "$i 20", 'Lwall');
        }
    }
    
    
    save_to_file('foyer', $map);
}


function save_to_file($name, $content) {
    $file = fopen(MAP_DIR.$name, 'w+');
    fwrite($file, $content);
    fclose($file);
}

function add_lisp_comment($comment, &$subject) {
    echo(';;'.$comment.NL);
    $subject .= INDENT.';;'.$comment."\n";
}

function add_map_line(&$map, $coordinates, $object_type) {
    echo($coordinates.NL);
    $map .= preg_replace(
        '#([0-9]+) ([0-9]+)#',
        INDENT.'('.$object_type.'\1:\2 0 \1 \2 0 0 () "'.$object_type
            .'" ,id-step ,id-collision ,id-action)'."\n",
        $coordinates
    );
}

function add_line_loud(&$string, $line) {
    echo $line.NL;
    $string .= $line."\n";
}
function lisp_map_line($numbers_list, $object_name) {
    $lines_ = explode("\n", $numbers_list);
    $lisp_list = preg_replace(
        '#([0-9]+) ([0-9]+)#',
        INDENT.'(WALL\1:\2 0 \1 \2 0 0 () "'.$object_name.'" ,id-step ,id-collision ,id-action)',
        $numbers_list
    );
    return $lisp_list;
}