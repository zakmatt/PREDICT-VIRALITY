function [ alphaOls ] = linearRegressorOls( v_n, v_168 )
    if ~isequal(size(v_n,1),size(v_168,1))
       alphaOls = 0; 
    else
       alphaOls = (v_n'*v_n)\v_n'*v_168;
    end

end

