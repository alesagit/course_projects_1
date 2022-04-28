// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;
pragma experimental ABIEncoderV2;

contract OMS_COVID {

    address public OMS;

    constructor () public {
        OMS = msg.sender;
    }

    mapping (address => bool) Validacion_CentroSalud;
    mapping (address => address) public CentroSalud_Contrato;

    address [] public direcciones_contratos_salud;
    address [] Solicitudes;

    event SolicitudAcceso (address);
    event NuevoCentroValidado (address);
    event NuevoContrato (address, address);

    modifier UnicamenteOMS(address _direccion) {
        require(_direccion == OMS, "No tienes permisos para realizar esta funcion");
        _;
    }

    function SolicitarAcceso() public {
        Solicitudes.push(msg.sender);
        emit SolicitudAcceso (msg.sender);
    }

    function VisualizarSolicitudes() public view UnicamenteOMS(msg.sender) returns (address [] memory) {
        return Solicitudes;
    }

    function CentrosSalud (address _centroSalud) public UnicamenteOMS(msg.sender) {
        Validacion_CentroSalud[_centroSalud] = true;
        emit NuevoCentroValidado(_centroSalud);
    }

    function FactoryCentroSalud() public {
        require(Validacion_CentroSalud[msg.sender] == true, "No tienes permisos para ejecutar esta funcion");
        address contrato_CentroSalud = address (new CentroSalud(msg.sender));
        direcciones_contratos_salud.push(contrato_CentroSalud);
        CentroSalud_Contrato[msg.sender] = contrato_CentroSalud;
        emit NuevoContrato(contrato_CentroSalud, msg.sender);
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////

contract CentroSalud {

    address public DireccionCentroSalud;
    address public DireccionContrato;

    constructor (address _direccion) public {
        DireccionCentroSalud = _direccion;
        DireccionContrato = address(this);
    }

    mapping (bytes32 => Resultados) ResultadosCOVID;

    struct Resultados {
        bool diagnostico;
        string CodigoIPFS;
    }

    event NuevoResultado (string, bool);

    modifier UnicamenteCentroSalud(address _direccion) {
        require (_direccion == DireccionCentroSalud, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    function ResultadosPruebaCovid(string memory _idPersona, bool _resultadoCOVID, string memory _codigoIPFS) public UnicamenteCentroSalud(msg.sender) {

        bytes32 hash_idPersona = keccak256 (abi.encodePacked(_idPersona));

        ResultadosCOVID[hash_idPersona] = Resultados(_resultadoCOVID, _codigoIPFS);

        emit NuevoResultado( _codigoIPFS, _resultadoCOVID);
    }

    function VisualizarResultados() public view returns (string memory _resultadoPrueba, string memory _codigoIPFS) {

        bytes32 hash_idPersona = keccak256 (abi.encodePacked(_idPersona));

        string memory resultadoPrueba;
        if (ResultadosCOVID[hash_idPersona].diagnostico == true) {
            resultadoPrueba = "Positivo";
        }else{
            resultadoPrueba = "Negativo";
        }

        _resultadoPrueba = resultadoPrueba;
        _codigoIPFS = ResultadosCOVID[hash_idPersona].CodigoIPFS;
    }
}