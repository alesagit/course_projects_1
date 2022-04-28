// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.9.0;
pragma experimental ABIEncoderV2;
import "./token.sol";

contract loteria {
    ERC20Basic private token;

    address public owner;
    address public contrato;

    uint tokens_creados = 10000;

    event ComprandoTokens (uint, address);

    constructor () public {
        token = new ERC20Basic(tokens_creados);
        owner = msg.sender;
        contrato = address(this);
    }
    /*
        #########
        # TOKEN #
        #########
    */
    function PrecioToken(uint _numTokens) internal pure returns (uint) {
        return _numTokens*(1 ether);
    }

    function GeneraTokens(uint _numTokens) public Unicamente(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    modifier Unicamente(address _direccion) {
        require (_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    function CompraTokens(uint _numTokens) public payable {
        uint coste = PrecioToken(_numTokens);
        require(msg.value >= coste, "Compra menos tokens o paga con mas ethers");
        uint returnValue = msg.value - coste;
        msg.sender.transfer(returnValue);
        uint Balance = TokensDisponibles();
        require(_numTokens <= Balance, "Compra un numero de tokens adecuado");
        token.transfer(msg.sender, _numTokens);
        emit ComprandoTokens(_numTokens, msg.sender);
    }

    function TokensDisponibles() public view returns (uint) {
        return token.balanceOf(contrato);
    }

    function Bote() public view returns (uint) {
        return token.balanceOf(owner);
    }

    function MisTokens() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }
    /*
        ###########
        # LOTERIA #
        ###########
    */
    uint public PrecioBoleto = 5;
    mapping (address => uint []) idPersona_boletos;
    mapping (uint => address) ADN_boleto;

    uint randNonce = 0;
    uint [] boletos_comprados;

    event boleto_comprado(uint, address);
    event boleto_ganador(uint);
    event tokens_devueltos(uint, address);

    function CompraBoleto(uint _boletos) public {
        uint precio_total = _boletos * PrecioBoleto;

        require(precio_total <= MisTokens(), "Necesitas comprar mas tokens");

        token.transferencia_loteria(msg.sender, owner, precio_total);

        for (uint i = 0; i < _boletos; i++) {
            uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 10000;
            randNonce++;
            idPersona_boletos[msg.sender].push(random);
            boletos_comprados.push(random);
            ADN_boleto[random] = msg.sender;
            emit boleto_comprado(random, msg.sender);
        }
    }

    function TusBoletos() public view returns (uint [] memory) {
        return idPersona_boletos[msg.sender];
    }

    function GenerarGanador() public Unicamente(msg.sender) {
        require(boletos_comprados.length > 0, "No hay bloetos comprados");

        uint longitud = boletos_comprados.length;
        uint posicion_array = uint (uint(keccak256(abi.encodePacked(now))) % longitud);
        uint eleccion = boletos_comprados[posicion_array];

        emit boleto_ganador(eleccion);

        address direccion_ganador = ADN_boleto[eleccion];

        token.transferencia_loteria(msg.sender, direccion_ganador, Bote());
    }

    function DevolverTokens(uint _numTokens) public payable {
        require(_numTokens > 0, "Necesitas devolver un numero positivo de tokens");
        require(_numTokens <= MisTokens(), "No tienes los tokens que intentas devolver");

        token.transferencia_loteria(msg.sender, address(this), _numTokens);

        msg.sender.transfer(PrecioToken(_numTokens));

        emit tokens_devueltos(_numTokens, msg.sender);
    }
}