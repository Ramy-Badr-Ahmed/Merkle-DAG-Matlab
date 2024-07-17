classdef MerkleDAG < handle
    properties
        Root        % Root node of the Merkle-DAG
        Nodes       % Cell array to store all nodes in the DAG
        HashAlgorithm   % Hashing algorithm (default: 'SHA-256')
    end
    
    methods
        function obj = MerkleDAG(dataBlocks, hashAlgorithm)            
            if nargin > 0
                if nargin < 2 || isempty(hashAlgorithm)
                    hashAlgorithm = 'SHA-256';  
                end                
                obj.HashAlgorithm = hashAlgorithm; 

                obj.Nodes = obj.buildDAG(dataBlocks);
                obj.setRoot(obj.Nodes{end});
            else
                obj.Root = [];
                obj.Nodes = {};
            end
        end

        %% Set the root node of the Merkle-DAG
        function setRoot(obj, rootNode)
            obj.Root = rootNode;
        end
        
        %% Build a Merkle-DAG from data blocks
        function nodes = buildDAG(obj, dataBlocks)            
            numBlocks = size(dataBlocks, 1);
            nodes = cell(numBlocks, 1);            
                     
            % Create leaf nodes
            for i = 1:numBlocks
                nodes{i} = MerkleDAGNode(dataBlocks(i, :), obj.HashAlgorithm, []);                                 
            end      
            
            % Build parent nodes iteratively until a single root node is created
            while numel(nodes) > 1                
                newSize = ceil(numel(nodes) / 2);   % Preallocate to half of the size of the current nodes
                level = cell(newSize, 1);                
                index = 1;

                for i = 1:2:numel(nodes)
                    if i == numel(nodes)
                        level{index} = nodes{i};
                    else
                        combinedHash = obj.computeHash([nodes{i}.Hash, nodes{i+1}.Hash]);
                        parentNode = MerkleDAGNode([], obj.HashAlgorithm, combinedHash);
                        parentNode.addChild(nodes{i});
                        parentNode.addChild(nodes{i+1});
                        level{index} = parentNode;
                    end
                    index = index + 1;
                end
                nodes = level;
            end
            
            % Store all nodes, including intermediate nodes
            obj.Nodes = nodes;
        end
        
        %% Verify the integrity of a specific block in the Merkle-DAG
        function isVerified = verifyBlock(obj, dataBlock)
            targetHash = obj.computeHash(dataBlock);
            isVerified = obj.verifyNode(obj.Root, targetHash);
        end

        %% Compute the cryptographic hash of the data: to verify the overall integrity of the DAG    
        function hash = computeHash(~, data)            
            persistent hasher;
            if isempty(hasher)
                hasher = java.security.MessageDigest.getInstance('SHA-256');
            end

            % Convert data to uint8
            if isnumeric(data)                
                serializedData = typecast(data(:), 'uint8');
            else                
                serializedData = uint8(data(:)');
            end
            hasher.update(serializedData(:));
            hash = char(reshape(dec2hex(typecast(hasher.digest(), 'uint8'))', 1, []));
        end

        %% Traverse Depth-First Search (DFS)
        function traverseDFS(obj)
            if isempty(obj.Root)
                disp('The DAG is empty.');
                return;
            end
            obj.traverseNodeDFS(obj.Root, 0);
        end 

        %% Traverse Breadth-First Search (BFS)
        function traverseBFS(obj)
            if isempty(obj.Root)
                disp('The DAG is empty.');
                return;
            end

            queue = {obj.Root}; 
            levels = 0;
            
            while ~isempty(queue)                
                node = queue{1};
                queue(1) = [];
                level = levels(1);
                levels(1) = [];

                indent = repmat('  ', 1, level);

                disp([indent, 'Node Data: ', mat2str(node.Data), ', Hash: ', node.Hash]);                

                for i = 1:numel(node.Children)
                    queue{end+1} = node.Children{i};
                    levels(end+1) = level + 1;      
                end                
            end
        end

    end
    
    methods (Access = private)
        %% Recursivly traverse each node
        function traverseNodeDFS(obj, node, level)
            indent = repmat('  ', 1, level);
            disp([indent, 'Node Data: ', mat2str(node.Data), ', Hash: ', node.Hash]);
            for i = 1:numel(node.Children)
                obj.traverseNodeDFS(node.Children{i}, level + 1);
            end
        end  

        %% Recursively verify the integrity of a node and its children
        function isVerified = verifyNode(obj, node, targetHash)
            if isempty(node.Children)
                isVerified = isequal(node.Hash, targetHash);
            else
                isVerified = any(cellfun(@(child) obj.verifyNode(child, targetHash), node.Children));
            end
        end

    end
end
