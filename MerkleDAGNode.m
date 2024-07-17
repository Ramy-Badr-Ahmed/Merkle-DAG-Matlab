classdef MerkleDAGNode < handle
    properties
        Data        % Data associated with the node
        Hash        % Stores the cryptographic hash of either the provided data or directly assigned hash
        Children    % Array of child nodes
        Parent      % Parent node
        HashAlgorithm   % Hashing algorithm (default: 'SHA-256')
    end
    
    methods
        function obj = MerkleDAGNode(data, hashAlgorithm, hash)            
            if nargin > 0
                if nargin < 2 || isempty(hashAlgorithm)
                    hashAlgorithm = 'SHA-256';  % Default to SHA-256 if not specified
                end
                
                obj.HashAlgorithm = hashAlgorithm;  

                if isempty(data)
                    obj.Data = [];
                    obj.Hash = hash;
                else
                    obj.Data = data;
                    obj.Hash = obj.computeHash(data);
                end
                obj.Children = {};
                obj.Parent = [];
            end
        end

        %% Add a child node to the current node    
        function addChild(obj, childNode)             
            obj.Children{end+1} = childNode;
            childNode.Parent = obj;
            obj.updateHash();           % Update hash of the current node after adding child
            obj.propagateHashUpdate();  % Propagate hash update up the graph
        end

        %% Update hash of the current node based on its data and children 
        function updateHash(obj)                    
            if isempty(obj.Children)
                obj.Hash = obj.computeHash(obj.Data); % Recompute hash if no children
            else
                childHashes = cellfun(@(child) child.Hash, obj.Children, 'UniformOutput', false);
                combinedHash = obj.computeHash([obj.Hash, childHashes{:}]);
                obj.Hash = combinedHash;
            end
        end    

        %%  Propagate hash update: recursively updates the hash of the current node's parent
        function propagateHashUpdate(obj)            
            parent = obj.Parent;
            while ~isempty(parent)
                parent.updateHash();
                parent = parent.Parent;
            end
        end        

        %% Compute the cryptographic hash of the data 
        function hash = computeHash(obj, data)              
            persistent hasher;
            if isempty(hasher) || ~isequal(hasher.getAlgorithm(), obj.HashAlgorithm)
                hasher = java.security.MessageDigest.getInstance(obj.HashAlgorithm);
            end
            
            % Convert to uint8
            if isnumeric(data)                
                serializedData = typecast(data(:), 'uint8');    
            else                
                serializedData = uint8(data(:)');
            end
            hasher.update(serializedData(:));
            hash = char(reshape(dec2hex(typecast(hasher.digest(), 'uint8'))', 1, []));
        end

    end
end
