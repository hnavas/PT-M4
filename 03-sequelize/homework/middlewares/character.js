const { Router } = require("express");
const { Op, Character, Role } = require("../db");
const router = Router();

router.post("/", async (req, res) => {
  const { code, name, age, race, hp, mana, date_added } = req.body;
  if (!code || !name || !hp || !mana) {
    return res.status(404).send("Falta enviar datos obligatorios");
  }
  try {
    const character = await Character.create(req.body);
    return res.status(201).json(character);
  } catch (error) {
    return res.status(404).send("Error en alguno de los datos provistos");
  }
});

router.get("/", async (req, res) => {
  const { name, hp, race, age } = req.query;
  if(name === 'true' && hp === 'true') {
    const characters = await Character.findAll({
      attributes: ["name", "hp"]
    });
    return res.json(characters.map(character => character.toJSON()));
  } 
  const condition = {};
  const where = {};
  if(race) where.race = race;
  if(age) where.age = age;
  condition.where = where;
  const characters = await Character.findAll(condition);
  return res.json(characters.map(character => character.toJSON()));
});

router.get("/young", async (req, res) => {
  const characters = await Character.findAll({
    where:{
      age:{
        [Op.lt]: 25
      }
    }
  });
  return res.json(characters.map(character => character.toJSON()));
});

router.get("/roles/:code", async (req, res) => {
  const { code } = req.params;
  const character = await Character.findByPk(code, {
    include: Role
  });
  res.json(character);
});

router.get("/:code", async (req, res) => {
  const { code } = req.params;
  const character = await Character.findByPk(code);
  if (!character) return res.status(404).send("El código FIFTH no corresponde a un personaje existente");
  return res.json(character.toJSON());
});

router.put('/addAbilities', async (req, res) => {
  const { codeCharacter, abilities } = req.body;
  const character = await Character.findByPk(codeCharacter);
  const promises = abilities.map(a => character.createAbility(a));
  await Promise.all(promises);
  res.send('Abilities Add');
});

router.put("/:attribute", async (req, res) => {
  const {attribute} = req.params;
  const {value} = req.query;
  await Character.update({ [attribute]: value }, {
     where: {
      [attribute]: null 
    } 
  });
  res.send('Personajes actualizados');
});

module.exports = router;
