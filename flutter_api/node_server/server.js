const express = require('express');
const mongoose = require('mongoose');
var jwt = require('jsonwebtoken');

const port = process.env.PORT || 5000;

//Database connection
async function connectDB() {
    mongoose.connect('mongodb://localhost:27017/node', { useNewUrlParser: true, useUnifiedTopology: true }).then(() => {
        console.log("Database connection established");
    });    
}

connectDB();

const app = express();

app.use(express.json({extended: false}));

//schema
var schema = new mongoose.Schema({ email: "string", password: "string" });
var User = mongoose.model("User", schema);

//root route
app.get('/', (req, res) => {
    res.send('Server up and running.');
});

//signup route
app.post('/signup/', async (req, res) => {
    const { email, password } = req.body;

    let user = await User.findOne({ email });

    if(user) {
        return res.json({ msg : 'User already taken.'})
    }

    user = new User({
      email,
      password,
    });
  
    await user.save();
    var token = jwt.sign({ id: user.id }, 'password');
    res.json({ token: token });
});

//login route
app.post('/login/', async (req, res) => {
    const { email, password } = req.body;
    console.log(email);
  
    let user = await User.findOne({ email });
    console.log(user);

    if(!user) {
        return res.json({msg : 'User not found'});
    }

    if(user.password !== password) { 
        return res.json({ msg : 'Incorrect password.'})
    }else {
        var token = jwt.sign({ id: user.id }, 'password');
        return res.json({ token: token });
    }

});

//private route
app.get('/token/', async (req, res) => {
    let token = req.header("token");

    if(!token) {
        return res.json({ msg : 'user not allowed.'});
    }

    var decoded = jwt.verify(token, "password");
    console.log(decoded.id);

    return res.json({msg: "token is valid"})

});


//server
app.listen(port, () => {
    console.log('Listening on port', port);
});