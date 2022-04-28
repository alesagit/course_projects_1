//SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;//libreria que contiene la funcion para calcular hashes

contract votacion{

    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    mapping (string=>bytes32) ID_Candidato;

    mapping (string=>uint) votos_candidato;

    string [] candidatos;

    bytes32 [] votantes;

    function Representar(string memory _nombrePersona, uint _edadPersona, string memory _idPersona) public{
        bytes32 hash_Candidato = keccak256(abi.encodePacked(_nombrePersona, _edadPersona, _idPersona));

        ID_Candidato[_nombrePersona] = hash_Candidato;

        candidatos.push(_nombrePersona);
    }

    function verCandidatos() public view returns(string[] memory){
        return candidatos;
    }

    function Votar(string memory _candidato) public{
        bytes32 hash_Votante = keccak256(abi.encodePacked(msg.sender));
        for(uint i = 0; i < votantes.length; i++){
            require(votantes[i] != hash_Votante, "Ya has votado previamente");
        }
        votantes.push(hash_Votante);
        votos_candidato[_candidato]++;
    }

    function VerVotos(string memory _candidato) public view returns(uint){
        return votos_candidato[_candidato];
    }

    function uint2str(uint _i) internal pure returns(string memory _uintAsString){
        if(_i == 0){
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0){
            bstr[k--] = byte(uint8(48+ _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function VerResultados() public view returns(string memory){
        string memory resultados = "";
        for(uint i = 0; i < candidatos.length; i++){
            resultados = string(abi.encodePacked(resultados, "(", candidatos[i], ", ", uint2str(VerVotos(candidatos[i])), ") --"));
        }
        return resultados;
    }

    function Ganador() public view returns(string memory){
        string memory ganador = candidatos[0];
        bool flag;
        for(uint i = 0; i < candidatos.length; i++){
            if(votos_candidato[ganador] < votos_candidato[candidatos[i]]){
                ganador = candidatos[i];
                flag = false;
            }else{
                if(votos_candidato[ganador] == votos_candidato[candidatos[i]]){
                    flag = true;
                }
            }
        }
        if(flag == true){
            ganador = "¡Hay un empate entre candidatos!";
        }
        return ganador;
    }
}