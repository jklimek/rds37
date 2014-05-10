<?php
class ShadowBuilder {
    
    public function build_cloud_layer($version) {
        $clouds_ = [];
        switch ($version) {
            case 1:
                $clouds_ = array_merge($clouds_, $this->build_cloud(1));
                break;

            default:
                break;
        }
        return $clouds_;
    }
    
    public function build_cloud($version) {
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
