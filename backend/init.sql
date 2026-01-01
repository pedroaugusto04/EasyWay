CREATE TABLE Users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    is_driver BOOLEAN DEFAULT FALSE,     
    device_token VARCHAR(255),
    lat DOUBLE PRECISION,       
    lng DOUBLE PRECISION        
);

-- Tabela de Motoristas
CREATE TABLE Drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), 
    user_id UUID REFERENCES Users(id) ON DELETE CASCADE,  -- Relacionado ao UUID do usuário
    is_active BOOLEAN DEFAULT FALSE,                      -- Status do motorista (ativo/inativo)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Rotas
CREATE TABLE Routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),         
    name VARCHAR(255) NOT NULL,
    origin VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    driver_id UUID REFERENCES Drivers(id) ON DELETE SET NULL,  -- Relacionado ao UUID do motorista
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Users_Routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),     
    user_id UUID REFERENCES Users(id) ON DELETE CASCADE, 
    route_id UUID REFERENCES Routes(id) ON DELETE CASCADE, 
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP     -- Data em que o usuário se juntou à rota
);

-- Procedimento para conceder o status de motorista
CREATE OR REPLACE PROCEDURE grant_driver(IN user_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Atualiza o campo is_driver do usuário para TRUE
    UPDATE Users
    SET is_driver = TRUE
    WHERE id = user_id;

    -- Insere um novo registro na tabela Drivers relacionado ao usuário
    INSERT INTO Drivers (user_id, is_active)
    VALUES (user_id, TRUE);
END;
$$;

-- Procedimento para revogar o status de motorista
CREATE OR REPLACE PROCEDURE revoke_driver(IN p_user_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Atualiza o campo is_driver do usuário para FALSE
    UPDATE Users
    SET is_driver = FALSE
    WHERE id = p_user_id;

    -- Atualiza o campo is_active do motorista para FALSE
    UPDATE Drivers
    SET is_active = FALSE
    WHERE user_id = p_user_id;  
END;
$$;

-- Procedimento para ativar o status de motorista
CREATE OR REPLACE PROCEDURE activate_driver(IN p_user_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Atualiza o campo is_driver do usuário para TRUE
    UPDATE Users
    SET is_driver = TRUE
    WHERE id = p_user_id;

    -- Atualiza o campo is_active do motorista para TRUE
    UPDATE Drivers
    SET is_active = TRUE
    WHERE user_id = p_user_id;  
END;
$$;
