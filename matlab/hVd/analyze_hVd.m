% analyze_hVd.m
%
% Purpose: Return vowel confusion matrices for all noise conditions.
%          Call with [C,cor] = analyze_hVd(subjname, subjnum, HAnum)
%
% Input: subjname (string), subjnum (string), HAnum (string)
%
% Output: C (cell), cor (double)
%
% Note: I have verified that this function works as it should.  With little 
%       work, it would be possible to extend to more noise conditions, and 
%       further phonemes as well.
function [C,cor] = analyze_hVd(subjname, subjnum, HAnum)

[a b c d e f] = read_data_file();

M = build_data_matrix();
% M's structure is:
% trial#, phoneme, response, person speaking, 'correct'/'incorrect', S/N

build_confusion_matrices();
% builds cell array (C) of confusion matrices


    function [a b c d e f] = read_data_file()
        
        curpath = mfilename('fullpath');
        curmfile = mfilename();
        curpath = curpath(1:(end-length(curmfile)));

        filename = strcat(curpath, 'data\', subjname, subjnum, HAnum, '.txt');
        [a b c d e f] = textread(filename, '%n %s %s %s %s %n');       
    
    end


    function [M] = build_data_matrix()
            
        % build cell array (M) holding all the pertinent data
        M = cell(length(a),6);

        for i=1:6
            for j=1:length(a)
                if i == 1
                    M{j,i} = a(j);
                elseif i == 2
                    M{j,i} = b{j};
                elseif i == 3
                    M{j,i} = c{j};
                elseif i == 4
                    M{j,i} = d{j};
                elseif i == 5
                    M{j,i} = e{j};
                else  % i == 6
                    M{j,i} = f(j);
                end 
            end
        end
        
        %replace 2nd col with phonemes
        %replace 4th col with person speaking
        phonemes = cell(length(a),1);
        persons = cell(length(a),1);
        for i=1:length(a)
            phonemes{i} = M{i,4}(4:5);
            persons{i} = M{i,4}(1:3);
        end
        for i=1:length(a)
            M{i,2} = phonemes{i};
            M{i,4} = persons{i};
        end
        
    end


    function build_confusion_matrices()
       
        noise_levels = [1000 5];  % 1000=quiet, 5=noise
        % 5=noise as the original program had +5 SNR, but now it is +7 SNR
        phoneme_labels = {'ae'; 'aw'; 'eh'; 'ei'; 'er'; 'ih'; 'iy'; 'oa'; 'oo'; 'uh'; 'uw'};
        
        % create separate confusion matrices for noise conditions and total
        % order is:    ae aw eh ei er ih iy oa oo uh uw
        C = cell(length(noise_levels)+1,1);
        for i=1:length(C)
           C{i} = zeros(11,11); 
        end
        
        % create % correct matrix
        cor = zeros(length(noise_levels)+1,1);
        
        % will find numeric indices corresponding to all ae, ..., uw
        % i rows: noise level 1, ..., noise level x
        phoneme_indices = cell(length(noise_levels),11);
        for i=1:length(noise_levels)
            for j=1:length(phoneme_indices)
                a = find(strcmp(M(:,2),phoneme_labels(j))==1);
                b = find(cell2mat(M(:,6))==noise_levels(i));
                phoneme_indices{i,j} = intersect(a,b);
            end
        end
        
        % builds confusion matrices for all noise conditions
        for i=1:length(noise_levels)
            for j=1:length(phoneme_labels)
                targ = phoneme_labels{j};
                for k=1:length(phoneme_indices{1,1})
                    resp = M(phoneme_indices{i,j}(k),3);
                    resp_index = find(strcmp(phoneme_labels,resp)==1);
                    C{i}(j,resp_index) = C{i}(j,resp_index)+1;
                end
            end
        end
        
        % builds the total confusion matrix
        C{length(C)} = C{1};
        for i=2:length(C)-1
            C{length(C)} = C{length(C)} + C{i};
        end
        
        % builds %cor matrix
        for i=1:length(cor)
            cor(i) = trace(C{i})/sum(sum(C{i}));
        end
        
    end


end