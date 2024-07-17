![MATLAB](https://img.shields.io/badge/MATLAB-%23D00000.svg?style=plastic&logo=mathworks&logoColor=white)

![GitHub](https://img.shields.io/github/license/Ramy-Badr-Ahmed/Merkle-DAG-Matlab?cached)

# Merkle-DAG Implementation in MATLAB

This repository contains MATLAB scripts for implementing and using a Merkle Directed Acyclic Graph (DAG) data structure.

The Merkle-DAG is a cryptographic data structure used to efficiently verify the integrity and consistency of data blocks.

### About

> [IPFS Link](https://docs.ipfs.tech/concepts/merkle-dag/)

### Features

- Build Merkle-DAG: Construct a Merkle-DAG manually or from data blocks.
- Traversal and Verification: Traverse the structure and verify the integrity of data blocks.
- Flexible Hash Algorithms: Ability to choose and change hash algorithms for computing node hashes.
   
    Supported algorithms from Java Security (via MATLAB)  
    ```matlab
    import java.security.MessageDigest;
    java.security.Security.getAlgorithms('MessageDigest')
    ```

### Scripts

1. `MerkleDAGNode.m`

   > Represents a node in the Merkle-DAG, holds data, compute hashes, and manage child nodes.

2. `MerkleDAG.m`

   > Constructs the Merkle-DAG from data blocks, performs integrity verification, and provides traversal methods (DFS & BFS).

### Example Usages

#### Manually Create the Merkle-DAG (Adding Nodes)

Use case: for scenarios where the DAG structure is not strictly determined by the data itself but by specific relationships or dependencies.

```matlab
node1 = MerkleDAGNode([1 2 3]);     % default: SHA-256, if no hash algorithm specified
node2 = MerkleDAGNode([4 5 6]);
node3 = MerkleDAGNode([7 8 9]);

% Add children to node1 (hash recursively updated)
node1.addChild(node2);
node1.addChild(node3);

% Add another child to node2    (hash recursively updated)
node4 = MerkleDAGNode([10 11 12]);
node2.addChild(node4);

% Display the Merkle-DAG structure
DAGGraph = MerkleDAG();
DAGGraph.setRoot(node1)
DAGGraph.traverseDFS();     % Depth-First (DFS) traversal
DAGGraph.traverseBFS();     % Breadth-First (BFS) traversal

```

#### Build DAG from data blocks

use case: automated, allowing constructing a Merkle-DAG from a matrix of data blocks.
Each row of the matrix represents a data block. The DAG is built by hashing these blocks into the graph. 
For scenarios where the relationships between data blocks are determined by their positions in the matrix.

```matlab
dataBlocks = [      // compose data of the MerkleDAG as a matrix
    1 2 3;
    4 5 6;
    7 8 9;
    10 11 12;
    13 14 15
];

merkleDAG = MerkleDAG(dataBlocks, 'SHA-384');

% Display the Merkle-DAG structure
merkleDAG.traverseDFS();     % Depth-First (DFS) traversal
merkleDAG.traverseBFS();     % Breadth-First (BFS) traversal
```

#### Integrity Verification

The verifyBlock method checks whether a specific data block is part of the Merkle-DAG. 
Computes the hash of the data block and verifying it against the hashes in the DAG.

```matlab
% Verify a specific data block 
dataBlockToVerify = [4 5 6];
merkleDAG.verifyBlock(dataBlockToVerify);
```
