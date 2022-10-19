const express = require('express');
const morgan = require('morgan');
const cookieparser = require('cookie-parser');

const app = express();

const users = [
  {id: 1, name: 'Franco', email: 'Franco@mail.com', password: '1234'},
  {id: 2, name: 'Toni', email: 'Toni@mail.com', password: '1234'}
]

app.use(morgan('dev'));

app.use(express.urlencoded({ extended: true }));

app.use(cookieparser());

const isAuthenticated = (req, res, next) => {
  const {userId} = req.cookies;
  if(!userId) return res.redirect('/login');
  next();
}

const isNotAuthenticated = (req, res, next) => {
  const {userId} = req.cookies;
  if(userId) return res.redirect('/home');
  next();
}

app.use((req, res, next) => {
  console.log(req.cookies);
  next();
});

app.get('/', (req, res) => {
  res.send(`
    <h1>Bienvenidos a Henry!</h1>
    ${req.cookies.userId ? `
      <a href='/home'>Perfil</a>
      <form method='post' action='/logout'>
        <button>Salir</button>
      </form>
      ` : `
      <a href='/login'>Ingresar</a>
      <a href='/register'>Registrarse</a>
      `}
  `)
});

app.get('/register', isNotAuthenticated, (req, res) => {
  res.send(`
    <h1>Registrarse</h1>
    <form method='post' action='/register'>
      <input name='name' placeholder='Nombre' required />
      <input type='email' name='email' placeholder='Email' required />
      <input type='password' name='password' placeholder='Contraseña' required />
      <input type='submit' value='Registrarse' />
    </form>
    <a href='/login'>Iniciar sesión</a>
  `)
});

app.get('/login',  isNotAuthenticated, (req, res) => {
  res.send(`
    <h1>Iniciar sesión</h1>
    <form method='post' action='/login'>
      <input type='email' name='email' placeholder='Email' required />
      <input type='password' name='password' placeholder='Contraseña' required />
      <input type='submit' value='Ingresar' />
    </form>
    <a href='/register'>Registrarse</a>
  `)
});

app.post('/login', (req, res) => {
  const {email, password} = req.body;
  if(!email || !password) return res.redirect('/login');
  const user = users.find(u => u.email === email && u.password === password);
  if(!user) return res.redirect('/login');
  res.cookie('userId', user.id);
  res.redirect('/home');
  
});

app.get('/home', isAuthenticated, (req, res) => {
  const { userId } = req.cookies;
  const user = users.find(u => u.id.toString() === userId)
    res.send(`
    <h1>Bienvenido ${user.name}</h1>
    <h4>${user.email}</h4>
    <a href='/'>Inicio</a>
  `)
});

app.post('/register', (req, res) => {
  // 1) Obtener el name, email y password desde el body del request
  // 2) Verificar que los tres datos hayan sido provistos
  // Si todos los datos fueron provistos:
  //   a) Buscar dentro del listado de usuarios si existe alguno que tenga dicho email para evitar
  //      que existan dos usuarios con mismo mail
  //   b) Crear un nuevo objeto con los datos del usuario y pushearlo al array de users
  //   c) Redirigir a la pantalla inicial '/'
  // En el caso de que ya exista un usuario con ese email o no se hayan provisto o
  // el name o el email o la password, redirigir a /register
  const { name, email, password } = req.body;
  if(!name || !email || !password) return res.redirect('/register');
  const user = users.find(u => u.email === email);
  if(user) return res.redirect('/register');
  users.push({
    id: users.length + 1,
    name,
    email,
    password
  });
  res.redirect('/');
});

app.post('/logout', (req, res) => {
  res.clearCookie('userId');
  res.redirect('/');
});

app.listen(3000, (err) => {
  if(err) {
   console.log(err);
 } else {
   console.log('Listening on localhost:3000');
 }
});
