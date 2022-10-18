HomeWork 02-sql

CREATE TABLE Actors (
	id INTEGER PRIMARY KEY,
	first_name TEXT NULL,
	last_name TEXT NULL,
	gender TEXT NULL
);

INSERT INTO Actors (first_name, last_name, gender)
VALUES ("Anyles", "Corales", "Ff");

CREATE TABLE Movies (
	id INTEGER PRIMARY KEY,
	name TEXT NULL,
	year INTEGER NULL,
	rank REAL NULL
);

INSERT INTO Movies (name, year, rank)
VALUES ("Armagedon", 2000, 9);

CREATE TABLE Roles (
	actor_id INTEGER NOT NULL,
	movie_id INTEGER NULL,
	role_name TEXT NULL,
	FOREIGN KEY (actor_id)
	REFERENCES Actors (id),
	FOREIGN KEY (movie_id)
	REFERENCES Movies (id)
);

INSERT INTO Roles (actor_id, movie_id, role_name)
VALUES (1, 1, "Protagonista");

//CONSULTAS A LA BASE DE DATOS

SELECT name, year FROM movies WHERE year=1902 AND rank>5;

//Todas las movies en un año
SELECT * 
FROM movies 
WHERE year=1984;

//Cantidad de movies segun el año
SELECT COUNT(*)  as total
FROM movies 
WHERE year=1984;

//Buscá actores que tengan el substring stack en su apellido.
SELECT * 
FROM actors 
WHERE last_name LIKE '%stack%';

//Buscá los 10 nombres y apellidos más populares entre los actores. Cuantos actores tienen cada uno de esos nombres y apellidos
SELECT first_name, last_name, COUNT(*) as total
FROM actors
GROUP BY lower(first_name), lower(last_name)
ORDER BY total DESC
LIMIT 10;

//Listá el top 100 de actores más activos junto con el número de roles que haya realizado.
SELECT first_name, last_name, COUNT(*) as total_roles
FROM actors
JOIN roles ON actors.id = roles.actor_id
GROUP BY actors.id
ORDER BY total_roles DESC
LIMIT 100;

//Cuantas películas tiene IMDB por género? Ordená la lista por el género menos popular.
SELECT genre, COUNT(*) as total
FROM movies_genres
GROUP BY genre
ORDER BY total;

//Listá el nombre y apellido de todos los actores que trabajaron en la película "Braveheart" de 1995, ordená la lista alfabéticamente por apellido.
-- actors (id) -- (actor_id) roles (movie_id) -- (id) movies
SELECT first_name, last_name
FROM actors
JOIN roles ON actors.id = roles.actor_id
JOIN movies ON roles.movie_id = movies.id
WHERE movies.name = 'Braveheart' AND movies.year = 1995
ORDER BY actors.last_name;

//Listá todos los directores que dirigieron una película de género 'Film-Noir' en un año bisiesto (para reducir la complejidad, asumí que cualquier año divisible por cuatro es bisiesto). Tu consulta debería devolver el nombre del director, el nombre de la peli y el año. Todo ordenado por el nombre de la película.
-- directors (id) -- (director_id) movies_directors (movie_id) -- (id) movies (id) -- (movie_id) movies_genres
SELECT d.first_name, d.last_name, m.name, m.year, mg.genre
FROM directors as d
JOIN movies_directors as md ON d.id = md.director_id
JOIN movies as m ON md.movie_id = m.id
JOIN movies_genres as mg ON mg.movie_id = m.id
WHERE mg.genre = 'Film-Noir' AND m.year % 4 = 0
ORDER BY m.name;

//Listá todos los actores que hayan trabajado con Kevin Bacon en películas de Drama (incluí el título de la peli). Excluí al señor Bacon de los resultados.
--filtro Id de las películas donde trabajo Bacon
--actors -- roles -- movies
SELECT m.id
FROM movies as m
JOIN roles as r ON m.id = r.movie_id
JOIN actors as a ON a.id = r.actor_id
WHERE a.first_name = 'Kevin' AND a.last_name = 'Bacon';

--actors -- roles -- movies -- movies_genres

SELECT DISTINCT a.first_name, a.last_name, m.name
FROM actors as a
JOIN roles as r ON a.id = r.actor_id
JOIN movies as m On r.movie_id = m.id
JOIN movies_genres as mg ON m.id = mg.movie_id
WHERE mg.genre = 'Drama' AND m.id IN (
	SELECT m.id
	FROM movies as m
	JOIN roles as r ON m.id = r.movie_id
	JOIN actors as a ON a.id = r.actor_id
	WHERE a.first_name = 'Kevin' AND a.last_name = 'Bacon'
) AND (a.first_name || a.last_name != 'KevinBacon')
ORDER BY a.last_name DESC;

//Qué actores actuaron en una película antes de 1900 y también en una película después del 2000.
--Filtro ID actores antes de 1900
SELECT r.actor_id
FROM roles as r
JOIN movies as m ON r.movie_id = m.id
WHERE m.year < 1900;

--Filtro ID actores despues del 2000
SELECT r.actor_id
FROM roles as r
JOIN movies as m ON r.movie_id = m.id
WHERE m.year > 2000;

--Filtro completo
SELECT *
FROM actors
WHERE id IN (
	SELECT r.actor_id
	FROM roles as r
	JOIN movies as m ON r.movie_id = m.id
	WHERE m.year < 1900
) AND id IN (
	SELECT r.actor_id
	FROM roles as r
	JOIN movies as m ON r.movie_id = m.id
	WHERE m.year > 2000
);

//Buscá actores que actuaron en cinco o más roles en la misma película después del año 1990. Noten que los ROLES pueden tener duplicados ocasionales, sobre los cuales no estamos interesados: queremos actores que hayan tenido cinco o más roles DISTINTOS (DISTINCT cough cough) en la misma película. Escribí un query que retorne los nombres del actor, el título de la película y el número de roles (siempre debería ser > 5).

SELECT a.first_name, a.last_name, m.name, COUNT(DISTINCT role) as total_roles
FROM actors as a 
JOIN roles as r ON a.id = r.actor_id
JOIN movies as m ON m.id = r.movie_id
WHERE m.year > 1990
GROUP BY a.id, m.id
HAVING COUNT(DISTINCT role) > 5;

//Para cada año, contá el número de películas en ese años que sólo tuvieron actrices femeninas.

--Filtro ID de movies con almenos un actor hombre
SELECT r.movie_id
FROM roles as r
JOIN actors as a ON a.id = r.actor_id
WHERE a.gender = 'M';

SELECT year, COUNT(DISTINCT id) as total
FROM movies
WHERE id NOT IN (
	SELECT r.movie_id
	FROM roles as r
	JOIN actors as a ON a.id = r.actor_id
	WHERE a.gender = 'M'
)
GROUP BY year
ORDER BY year;