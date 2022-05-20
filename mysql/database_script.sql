CREATE DATABASE anidex;

USE anidex;

CREATE TABLE user
(
	userId INT NOT NULL,
	name VARCHAR(45) NOT NULL,
	email VARCHAR(45) NOT NULL,
	dob DATE,
	PRIMARY KEY (userId)
);

CREATE TABLE franchise
(
	franchiseId INT NOT NULL,
	name VARCHAR(45) NOT NULL,
	genres VARCHAR(200),
	demography VARCHAR(45),
	themes VARCHAR(200),
	averageScore FLOAT,
	PRIMARY KEY (franchiseId)
);

CREATE TABLE company
(
	companyId INT NOT NULL,
	name VARCHAR(45) NOT NULL,
	PRIMARY KEY (companyId)
);

CREATE TABLE studio
(
	studioId INT NOT NULL,
	PRIMARY KEY (studioId),
	FOREIGN KEY (studioId) REFERENCES company(companyId)
);

CREATE TABLE anime
(
	animeId INT NOT NULL,
	title VARCHAR(45) NOT NULL,
	franchiseId INT NOT NULL,
	studioId INT NOT NULL,
	type ENUM('TV', 'movie', 'OVA', 'ONA', 'special'),
	numEpisodes INT,
	episodeDuration INT,
	demography ENUM('shonen', 'shoujo', 'seinen', 'josei'),
	dateOfAir DATE,
	dateOfFinish DATE,
	genres VARCHAR(200),
	status ENUM('airing', 'aired', 'notaired') NOT NULL DEFAULT 'notaired',
	averageScore FLOAT,
	numScored INT,
	PRIMARY KEY (animeId),
	FOREIGN KEY (franchiseId) REFERENCES franchise(franchiseId),
	FOREIGN KEY (studioId) REFERENCES studio(studioId)
);

CREATE TABLE theme
(
	themeId INT NOT NULL,
	name VARCHAR(45) NOT NULL,
	PRIMARY KEY (themeId)
);

CREATE TABLE animetheme
(
	animeId INT NOT NULL,
	themeId INT NOT NULL,
	PRIMARY KEY (animeId, themeId),
	FOREIGN KEY (animeId) REFERENCES anime(animeId),
	FOREIGN KEY (themeId) REFERENCES theme(themeId)
);

CREATE TABLE entry
(
	userId INT NOT NULL,
	animeId INT NOT NULL,
	score INT,
	status ENUM('watching', 'plantowatch', 'completed', 'onhold', 'dropped') NOT NULL,
	startDate DATE,
	endDate DATE,
	numEpisodesSeen INT,
	PRIMARY KEY (userId, animeId),
	FOREIGN KEY (userId) REFERENCES user(userId),
	FOREIGN KEY (animeId) REFERENCES anime(animeId)
);

CREATE TABLE producer
(
	producerId INT NOT NULL,
	PRIMARY KEY (producerId),
	FOREIGN KEY (producerId) REFERENCES company(companyId)
);

CREATE TABLE production
(
	producerId INT NOT NULL,
	animeId INT NOT NULL,
	PRIMARY KEY (producerId, animeId),                                      	
	FOREIGN KEY (producerId) REFERENCES producer(producerId),
	FOREIGN KEY (animeId) REFERENCES anime(animeId)
);

CREATE TABLE staffmember
(
	memberId INT NOT NULL,
	companyId INT NOT NULL,
	name VARCHAR(45) NOT NULL,
	role  VARCHAR(45),
	dob DATE,
	PRIMARY KEY (memberId),
	FOREIGN KEY (companyId) REFERENCES company(companyId)
);

CREATE TABLE realization
(
	animeId INT NOT NULL,
	memberId INT NOT NULL,
	PRIMARY KEY (animeId, memberId),
	FOREIGN KEY (animeId) REFERENCES anime(animeId),
	FOREIGN KEY (memberId) REFERENCES staffmember(memberId)
);

CREATE TABLE character_
(
	characterId INT NOT NULL,
	name VARCHAR(45) NOT NULL,
	dob DATE,
	PRIMARY KEY (characterId)
);

CREATE TABLE starring
(
	animeId INT NOT NULL,
	characterId INT NOT NULL,
	role VARCHAR(45),
	PRIMARY KEY (animeId, characterId),
	FOREIGN KEY (animeId) REFERENCES anime(animeId),
	FOREIGN KEY (characterId) REFERENCES character_(characterId)
);

CREATE TABLE voiceactor
(
	vactId INT NOT NULL,
	PRIMARY KEY (vactId),
	FOREIGN KEY (vactId) REFERENCES staffmember(memberId)
);

CREATE TABLE interpretation
(
	vactId INT NOT NULL,
	characterId INT NOT NULL,
	PRIMARY KEY (vactId, characterId),
	FOREIGN KEY (vactId) REFERENCES voiceactor(vactId),
	FOREIGN KEY (characterId) REFERENCES character_(characterId)
);
 


