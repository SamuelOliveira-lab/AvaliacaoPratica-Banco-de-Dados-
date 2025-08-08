-- Questão 1
SELECT B.descricao AS Banco, A.sigla AS Agencia, COUNT(F.codPessoa) AS QuantidadeFuncionario,
 MAX(F.salario) AS MaiorSalario, AVG(F.salario) AS MediaSalario
FROM Banco AS B
INNER JOIN Agencia AS A ON B.codBanco = A.codBanco
LEFT JOIN Funcionario AS F ON F.codAgencia = A.codAgencia
GROUP BY B.descricao, A.sigla;

-- Questão 2

SELECT A.sigla AS Agencia, P.nome, F.registroTrabalho, F.salario
FROM Pessoa AS P
INNER JOIN Funcionario AS F ON F.codPessoa = P.codPessoa
INNER JOIN Agencia AS A ON A.codAgencia = F.codAgencia
INNER JOIN Banco AS B ON A.codBanco = B.codBanco
WHERE
B.descricao = 'Banco do Brasil'
AND P.codPessoa NOT IN (SELECT DISTINCT codPessoaGerente FROM Conta);

-- Questão 3

UPDATE Conta
SET saldo = (SELECT IFNULL(SUM(CASE WHEN tipo = 'C' THEN valor ELSE 0 END), 0)
- IFNULL(SUM(CASE WHEN tipo = 'D' THEN valor ELSE 0 END), 0)
FROM lancamento
WHERE codConta = Conta.codConta);

--  Questão 4

DELIMITER $$
CREATE TRIGGER RegistroPessoaCliente BEFORE INSERT
ON Cliente FOR EACH ROW
BEGIN
DECLARE quantidade INT;
SET quantidade := (SELECT COUNT(1) FROM Funcionario WHERE codPessoa = NEW.codPessoa);
IF(quantidade > 0) THEN
-- Gera uma exceção personalizada com uma mensagem
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'O codPessoa informado já existe na tabela Funcionario.';
END IF;
END$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER RegistroPessoaFuncionario BEFORE INSERT
ON Funcionario FOR EACH ROW
BEGIN
DECLARE quantidade INT;
SET quantidade := (SELECT COUNT(1) FROM Cliente WHERE codPessoa = NEW.codPessoa);
IF(quantidade > 0) THEN
-- Gera uma exceção personalizada com uma mensagem
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'O codPessoa informado já existe na tabela Cliente.';
END IF;
END$$
DELIMITER ;

-- Questão 5

CREATE VIEW GerenteSalarioAcimaMedia AS
SELECT DISTINCT A.sigla AS Agencia, P.nome As Funcionario, F.registroTrabalho AS RegistroTrabalho, F.salario
AS Salario
FROM Pessoa AS P
INNER JOIN Funcionario AS F ON F.codPessoa = P.codPessoa
INNER JOIN Conta AS C ON C.codPessoaGerente = F.codPessoa
INNER JOIN Agencia AS A ON A.codAgencia = F.codAgencia
WHERE
F.salario > (SELECT AVG(F.salario)
FROM Funcionario AS F
INNER JOIN Conta AS C ON C.codPessoaGerente = F.codPessoa);

--Questão 6

SELECT B.descricao AS Banco, SUM(F.salario) AS FolhaSalario
FROM Banco AS B
INNER JOIN Agencia AS A ON B.codBanco = A.codBanco
LEFT JOIN Funcionario AS F ON F.codAgencia = A.codAgencia
GROUP BY B.descricao
ORDER BY SUM(F.salario) DESC
LIMIT 1;

-- Questão 7

SELECT P.nome, F.registroTrabalho, COUNT(C.codConta) AS Quantidade
FROM Pessoa AS P
INNER JOIN Funcionario AS F ON F.codPessoa = P.codPessoa
LEFT JOIN Conta AS C ON F.codPessoa = C.codPessoaGerente
GROUP BY P.codPessoa
ORDER BY P.nome;
