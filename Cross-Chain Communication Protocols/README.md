# Rock Paper Scissors

**Xiaoxi Celia Lyu, Junyu Jason Liu, Wangkai Jin**

## Aim of this project:

The emergence of new chains (e.g. Solana, BSC) demands more frequent Cross-Chain (CC) communications than ever before. Our group finds that a systematization of to-date CC techniques is lacking since previous surveys either focus on a sub-field of CC [1] or omit novel attack and defense techniques [2, 3]. 

- In this project, we propose to present a systematization of knowledge on CC techniques that complements the missing parts of previous works. Our survey can be divided into three parts, which are CC protocols, their applications, and relevant attack and defense techniques.
First, we provide a review of prominent CC protocols (e.g., HTLC [4] and BTC Relay [5]). We discover that many recent developments in the area focus on standardizing CC messaging/communication, such as Cross-Chain Interoperability Protocol (CCIP) by Chainlink [6] and Cross-Consensus Message Format (XCM) by Polkadot [7].
- Second, we aim to discuss key technologies in CC (e.g., side-chains, rollups) which breed various use cases in real world. For example, CC-enabled asset transfers bring advanced trading experience (e.g., Central Bank Digital Currencies (CBDCs) [8]. Other potential use cases includes trustless collaboration (e.g., in Supply Chain cooperation [9]), User Identification and data portability [10], etc.
- Lastly, we aim to investigate novel attack and defense techniques for CC designs. For instance, the vulnerabilities of CCs can be exploited by certain side-channel attacks (e.g. [11]) and there are numerous solutions that leverage various methods for building secure and privacy-preserving CCs (e.g., Formal Proof [12], Atomic Swaps [13], CP-SNARK- based verification [14]).

As CC is a heated topic in the field, there are already several surveys that cover aspects of this technology. [3] presents a detailed summary of the existing CC protocols. [2] systematizes the interoperability of current blockchains and expands the discussion scope beyond transferring cryptocurrencies among different chains. [1] summarizes the existing challenges of current Layer 2 scaling and discusses the trade-offs of choosing different scaling techniques. The notable differences between our work with all the existing surveys are that 1) we include novel CC bridge contracts and 2) we systematically discuss the attack and defense techniques for CCs, of which the knowledge is fragmented in the existing literature.


## Documents Description

- `[report]SoK.pdf`: The codes of this smart contract in Solidity

Link to our presentation of this group project: https://youtu.be/S8fYaZBwKrE


## References

[1] C. Sguanci, R. Spatafora, and A. M. Vergani, “Layer 2 blockchain scaling: a survey,” 2021.

[2] R. Belchior, A. Vasconcelos, S. Guerreiro, and M. Correia, “A survey on blockchain interoperability: Past, present, and future trends,” 2020.

[3] P. Robinson, “Survey of crosschain communications protocols,” 2020.

[4] T. Nolan, “Alt chains and atomic transfers,” May 2013.

[5] J. Chow, “BTC Relay Documentation,” September 2016.

[6] Chainlink, “Introducing the cross-chain interoperability protocol (CCIP),” Aug 2021.

[7] R. Dasari, E. Surmeli, K. Yeung, and K. Alfaro, “Cross-Consensus Message Format (XCM),” Sep 2022.

[8] H. Sun, H. Mao, X. Bai, Z. Chen, K. Hu, and W. Yu, “Multi-blockchain model for central bank digital currency,” in 2017 18th International Conference on Parallel and Distributed Computing, Applications and Technologies (PDCAT), pp. 360–367, 2017.

[9] A. Sardon, T. Hardjono, and M. McBride, “Blockchain Gateways: Use-Cases,” Internet-Draft draft-sardon-blockchain-gateways-usecases-03, Internet Engineering Task Force, Apr. 2022. Work in Progress.

[10] R. Belchior, B. Putz, G. Pernul, M. Correia, A. Vasconcelos, and S. Guerreiro, “Ssibac: Self-sovereign identity based access control,” in 2020 IEEE 19th Interna- tional Conference on Trust, Security and Privacy in Computing and Communications (TrustCom), pp. 1935–1943, 2020.

[11] F. Tramèr, D. Boneh, and K. Paterson, “Remote Side-Channel attacks on anony- mous transactions,” in 29th USENIX Security Symposium (USENIX Security 20), pp. 2739–2756, USENIX Association, Aug. 2020.

[12] Z. Nehaï, F. Bobot, S. Tucci-Piergiovanni, C. Delporte-Gallet, and H. Faucon- nier, “A tla+ formal proof of a cross-chain swap,” in 23rd International Conference on Distributed Computing and Networking, ICDCN 2022, (New York, NY, USA), p. 148–159, Association for Computing Machinery, 2022.

[13] Y. Manevich and A. Akavia, “Cross chain atomic swaps in the absence of time via attribute verifiable timed commitments,” in 2022 IEEE 7th European Symposium on Security and Privacy (EuroSP), pp. 606–625, 2022.

[14] Y. Li, J. Weng, M. Li, W. Wu, J. Weng, J.-N. Liu, and S. Hu, “Zerocross: A sidechain- based privacy-preserving cross-chain solution for monero,” Journal of Parallel and Distributed Computing, vol. 169, pp. 301–316, 2022.
