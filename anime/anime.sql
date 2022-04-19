CREATE TABLE anime
(
    mal_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    type ENUM('TV', 'Movie', 'OVA', 'ONA', 'Special', 'Music', 'Unknown') NOT NULL DEFAULT 'Unknown',
    
    status ENUM('Finished Airing', 'Currently Airing', 'Not yet aired') NOT NULL DEFAULT 'Not yet aired',
    episodes INT,
    start DATE,
    end DATE,

    score FLOAT,
    scored_by INT NOT NULL DEFAULT 0,

    PRIMARY KEY (mal_id)

);