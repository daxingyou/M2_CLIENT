
--------------------------------
-- @module JumpTiles3D
-- @extend TiledGrid3DAction
-- @parent_module cc

--------------------------------
-- brief Set the amplitude rate of the effect.<br>
-- param amplitudeRate The value of amplitude rate will be set.
-- @function [parent=#JumpTiles3D] setAmplitudeRate 
-- @param self
-- @param #float amplitudeRate
-- @return JumpTiles3D#JumpTiles3D self (return value: cc.JumpTiles3D)
        
--------------------------------
-- brief Initializes the action with the number of jumps, the sin amplitude, the grid size and the duration.<br>
-- param duration Specify the duration of the JumpTiles3D action. It's a value in seconds.<br>
-- param gridSize Specify the size of the grid.<br>
-- param numberOfJumps Specify the jump tiles count.<br>
-- param amplitude Specify the amplitude of the JumpTiles3D action.<br>
-- return If the initialization success, return true; otherwise, return false.
-- @function [parent=#JumpTiles3D] initWithDuration 
-- @param self
-- @param #float duration
-- @param #size_table gridSize
-- @param #unsigned int numberOfJumps
-- @param #float amplitude
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- brief Get the amplitude of the effect.<br>
-- return Return the amplitude of the effect.
-- @function [parent=#JumpTiles3D] getAmplitude 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- brief Get the amplitude rate of the effect.<br>
-- return Return the amplitude rate of the effect.
-- @function [parent=#JumpTiles3D] getAmplitudeRate 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- brief Set the amplitude to the effect.<br>
-- param amplitude The value of amplitude will be set.
-- @function [parent=#JumpTiles3D] setAmplitude 
-- @param self
-- @param #float amplitude
-- @return JumpTiles3D#JumpTiles3D self (return value: cc.JumpTiles3D)
        
--------------------------------
-- brief Create the action with the number of jumps, the sin amplitude, the grid size and the duration.<br>
-- param duration Specify the duration of the JumpTiles3D action. It's a value in seconds.<br>
-- param gridSize Specify the size of the grid.<br>
-- param numberOfJumps Specify the jump tiles count.<br>
-- param amplitude Specify the amplitude of the JumpTiles3D action.<br>
-- return If the creation success, return a pointer of JumpTiles3D action; otherwise, return nil.
-- @function [parent=#JumpTiles3D] create 
-- @param self
-- @param #float duration
-- @param #size_table gridSize
-- @param #unsigned int numberOfJumps
-- @param #float amplitude
-- @return JumpTiles3D#JumpTiles3D ret (return value: cc.JumpTiles3D)
        
--------------------------------
-- 
-- @function [parent=#JumpTiles3D] clone 
-- @param self
-- @return JumpTiles3D#JumpTiles3D ret (return value: cc.JumpTiles3D)
        
--------------------------------
-- 
-- @function [parent=#JumpTiles3D] update 
-- @param self
-- @param #float time
-- @return JumpTiles3D#JumpTiles3D self (return value: cc.JumpTiles3D)
        
--------------------------------
-- 
-- @function [parent=#JumpTiles3D] JumpTiles3D 
-- @param self
-- @return JumpTiles3D#JumpTiles3D self (return value: cc.JumpTiles3D)
        
return nil
