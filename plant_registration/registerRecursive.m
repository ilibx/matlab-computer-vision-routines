%REGISTER_VIA_SURFACE_SUBDIVISION Do a coarse to fine, recursive
%registration.
function [Y1,Y2,Y3,Y_unreg] = ...
        registerRecursive( X,Y,opt,MIN_SIZE,MAX_REG_DIST )
    iter_num=0;
    [idx_y_unreg,idx_y_reg] = findPointIndicesToNotRegister( X,Y,MAX_REG_DIST );
    [Y1,Y2,Y3] = ...
                registerPoints( X,Y(idx_y_reg,:),opt,MIN_SIZE,MAX_REG_DIST,iter_num );
       % registerPoints( X,Y,opt,MIN_SIZE,MAX_REG_DIST,iter_num );
    Y_unreg = Y(idx_y_unreg,:);
end
 
function [X__,Y__,Z__] = registerPoints( X,Y,opt,MIN_SIZE,max_dist,iter_num )   
    if size(X,1) > MIN_SIZE && size(Y,1) > MIN_SIZE && max_dist >= 1 && iter_num < 4
        if iter_num > 0
            T = cpd_register(X,Y,opt);
            Y = T.Y;
        end
        
        min_x = min( [ X(:,1); Y(:,1) ] );
        max_x = max( [ X(:,1); Y(:,1) ] );
        min_y = min( [ X(:,2); Y(:,2) ] );
        max_y = max( [ X(:,2); Y(:,2) ] );
        min_z = min( [ X(:,3); Y(:,3) ] ); 
        max_z = max( [ X(:,3); Y(:,3) ] );

        % padding does not work because 
        % we are just dividing in half.       
        
        % this use of X co-ords as the dividing space is on purpose
        left_y   = min_x;
        right_y  = max_x;
        top_y    = max_y;
        bottom_y = min_y;
        back_y   = min_z;
        front_y  = max_z ;     
        
        m_width_y  = left_y+((right_y-left_y)/2);
        m_height_y = bottom_y+((top_y-bottom_y)/2);
        m_depth_y = back_y+((front_y-back_y)/2 );
        
        Y1_ = Y(:,1);
        Y2_ = Y(:,2);
        Y3_ = Y(:,3);
        
        k = 10;
        idx_y_000 = find( Y1_ < m_width_y & Y2_ < m_height_y & Y3_ < m_depth_y );
        idx_y_001 = find( Y1_ < m_width_y & Y2_ < m_height_y & Y3_ >= m_depth_y );
        idx_y_010 = find( Y1_ < m_width_y & Y2_ >= m_height_y & Y3_ < m_depth_y );
        idx_y_011 = find( Y1_ < m_width_y & Y2_ >= m_height_y & Y3_ >= m_depth_y );
        idx_y_100 = find( Y1_ >= m_width_y & Y2_ < m_height_y & Y3_ < m_depth_y );
        idx_y_101 = find( Y1_ >= m_width_y & Y2_ < m_height_y & Y3_ >= m_depth_y );
        idx_y_110 = find( Y1_ >= m_width_y & Y2_ >= m_height_y & Y3_ < m_depth_y );
        idx_y_111 = find( Y1_ >= m_width_y & Y2_ >= m_height_y & Y3_ >= m_depth_y );
        
        X_ur_000 = findPointstoRegister( X,Y(idx_y_000,:),k,max_dist )
        X_ur_001 = findPointstoRegister( X,Y(idx_y_001,:),k,max_dist )
        X_ur_010 = findPointstoRegister( X,Y(idx_y_010,:),k,max_dist )        
        X_ur_011 = findPointstoRegister( X,Y(idx_y_011,:),k,max_dist )        
        X_ur_100 = findPointstoRegister( X,Y(idx_y_100,:),k,max_dist )        
        X_ur_101 = findPointstoRegister( X,Y(idx_y_101,:),k,max_dist )        
        X_ur_110 = findPointstoRegister( X,Y(idx_y_110,:),k,max_dist )
        X_ur_111 = findPointstoRegister( X,Y(idx_y_111,:),k,max_dist )        

        
        
        %make fgt = 0 for the smaller subdivisions
        [Y1_000,Y2_000,Y3_000] = registerPoints( X_ur_000,Y(idx_y_000,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        %idx_x_000 = 0; idx_y_000 = 0;
        [Y1_001,Y2_001,Y3_001] = registerPoints( X_ur_001,Y(idx_y_001,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        %idx_x_001 = 0; idx_y_001 = 0;
        [Y1_010,Y2_010,Y3_010] = registerPoints( X_ur_010,Y(idx_y_010,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        %idx_x_010 = 0; idx_y_010 = 0;
        [Y1_011,Y2_011,Y3_011] = registerPoints( X_ur_011,Y(idx_y_011,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        %idx_x_011 = 0; idx_y_011 = 0;
        [Y1_100,Y2_100,Y3_100] = registerPoints( X_ur_100,Y(idx_y_100,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        %idx_x_100 = 0; idx_y_100 = 0;
        [Y1_101,Y2_101,Y3_101] = registerPoints( X_ur_101,Y(idx_y_101,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        %idx_x_101 = 0; idx_y_101 = 0;
        [Y1_110,Y2_110,Y3_110] = registerPoints( X_ur_110,Y(idx_y_110,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        %idx_x_110 = 0; idx_y_110 = 0;
        [Y1_111,Y2_111,Y3_111] = registerPoints( X_ur_111,Y(idx_y_111,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        %idx_x_111 = 0; idx_y_111 = 0;
        X__ = [Y1_000; Y1_001 ; Y1_010 ; Y1_011 ; Y1_100 ; Y1_101 ; Y1_110 ; Y1_111 ]; 
        Y__ = [Y2_000; Y2_001 ; Y2_010 ; Y2_011 ; Y2_100 ; Y2_101 ; Y2_110 ; Y2_111 ];  
        Z__ = [Y3_000; Y3_001 ; Y3_010 ; Y3_011 ; Y3_100 ; Y3_101 ; Y3_110 ; Y3_111 ]; 
   %{
    elseif size(X,1) > 100 && size(Y,1) > 100
        [R,T] = icp( X,Y );
        Y_icp = R*Y' + repmat(T',size(Y,1),1)';
        Y_icp = Y_icp';
        X__ = Y_icp(:,1);
        Y__ = Y_icp(:,2);
        Z__ = Y_icp(:,3);
    %}
    else
        X__ = Y(:,1);
        Y__ = Y(:,2);
        Z__ = Y(:,3);
    end

end
