<?php
class ShadowBuilder {
    
    public function build_cloud_layer($version) {
        $clouds_ = [];
        switch ($version) {
            case 1:
                $clouds_ = $this->_merge_shadows(
                    $this->_shift($this->_build_cloud(1), 10, 10),
                    $this->_shift($this->_flip_horizontal($this->_build_cloud(1)), 2, 20)
                );
                break;

            default:
                break;
        }
        return $clouds_;
    }
    
    private function _merge_shadows() {
        $shadows_deep_array_ = [];
        foreach (func_get_args() as $shadows_) {
            foreach($shadows_ as $shadow_){
                $x = $shadow_[0];
                $y = $shadow_[1];
                if (!isset($shadows_deep_array_[$x][$y]) || $shadows_deep_array_[$x][$y] !== 2) {
                    $shadows_deep_array_[$x][$y] = $shadow_['val'];
                }
            }
        }
        
        $shadows_ = [];
        foreach ($shadows_deep_array_ as $x => $shadows_level_y) {
            foreach ($shadows_level_y as $y => $shadow_value_) {
                $shadows_[] = [$x, $y, 'val'=>$shadow_value_];
            }
        }
        return $shadows_;
    }
    
    private function _shift($shadow_, $x, $y) {
        foreach ($shadow_ as &$shadow_part_) {
            $shadow_part_[0] += $x;
            $shadow_part_[1] += $y;
        }
        return $shadow_;
    }
    
    private function _flip_horizontal($shadow_) {
        $max_x = 0;
        foreach ($shadow_ as &$shadow_element_) {
            if ($shadow_element_[0] > $max_x) {
                $max_x = $shadow_element_[0];
            }
            $shadow_element_[0] *= -1;
        }
        
        foreach ($shadow_ as &$shadow_element_) {
            $shadow_element_[0] += $max_x + 1;
        }
        return $shadow_;
    }
    
    private function _flip_vertical($shadow_) {
        $max_y = 0;
        foreach ($shadow_ as &$shadow_element_) {
            if ($shadow_element_[1] > $max_y) {
                $max_y = $shadow_element_[1];
            }
            $shadow_element_[1] *= -1;
        }
        
        foreach ($shadow_ as &$shadow_element_) {
            $shadow_element_[1] += $max_y + 1;
        }
        return $shadow_;
    }
    
    private function _flip_both($shadow_) {
        return $this->_flip_horizontal($this->_flip_vertical($shadow_));
    }
    
    private function _build_cloud($version) {
        switch ($version) {
            case 1:
                $cloud_ = [
                    [3, 1, 'val' => 2],
                    [4, 1, 'val' => 2],
                    [2, 2, 'val' => 2],
                    [3, 2, 'val' => 1],
                    [4, 2, 'val' => 2],
                    [5, 2, 'val' => 2],
                    [6, 2, 'val' => 2],
                    [1, 3, 'val' => 2],
                    [2, 3, 'val' => 1],
                    [3, 3, 'val' => 1],
                    [4, 3, 'val' => 1],
                    [5, 3, 'val' => 1],
                    [6, 3, 'val' => 2],
                    [7, 3, 'val' => 2],
                    [1, 4, 'val' => 2],
                    [2, 4, 'val' => 2],
                    [3, 4, 'val' => 1],
                    [4, 4, 'val' => 1],
                    [5, 4, 'val' => 1],
                    [6, 4, 'val' => 2],
                    [7, 4, 'val' => 2],
                    [2, 5, 'val' => 2],
                    [3, 5, 'val' => 2],
                    [4, 5, 'val' => 1],
                    [5, 5, 'val' => 2],
                    [3, 6, 'val' => 2],
                    [4, 6, 'val' => 2],
                ];
                break;

            default:
                $cloud_ = [];
                break;
        }
        return $cloud_;
    }

}
