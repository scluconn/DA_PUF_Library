
function placementType_AAAA(xStart, yStart, fid, prefix, APUF_index, nStage)

    x = xStart;
    y = yStart;
    k = APUF_index;
    i = 0;
        
    fprintf(fid,'\n// APUF %d\n\n',k-1);
    
    while(i < nStage)
        fprintf(fid,[prefix 'SWITCH_CHAIN/STAGE[%d].SW/SW" LOC = SLICE_X%dY%d; \n'],k-1,i,x,y);
        fprintf(fid,[prefix 'SWITCH_CHAIN/STAGE[%d].SW/SW" BEL = A6LUT; \n'],k-1,i);
                
        i = i + 1 ; 
        y = y + 1;
    end 

    fprintf(fid,[prefix 'tigReg" BEL = AFF;\n'],k-1);
    fprintf(fid,[prefix 'tigReg" LOC = SLICE_X%dY%d;\n\n'],k-1,xStart,yStart-1);
    
    fprintf(fid,[prefix 'tigSignal_inv1_INV_0" BEL = B6LUT;\n'],k-1);
    fprintf(fid,[prefix 'tigSignal_inv1_INV_0" LOC = SLICE_X%dY%d;\n\n'],k-1,xStart,yStart-1);

    % Arbiter using SR latch
    fprintf(fid,[prefix 'ARBITER/X" LOC = SLICE_X%dY%d; \n'],k-1,x,y);
    fprintf(fid,[prefix 'ARBITER/X" BEL = A6LUT; \n'],k-1);
    fprintf(fid,[prefix 'ARBITER/Y" LOC = SLICE_X%dY%d; \n'],k-1,x,y);
    fprintf(fid,[prefix 'ARBITER/Y" BEL = B6LUT; \n\n'],k-1);

    fprintf(fid,[prefix 'respReady1" BEL = D6LUT;\n'],k-1);
    fprintf(fid,[prefix 'respReady1" LOC = SLICE_X%dY%d;\n\n'],k-1,x+1,y);
    
end