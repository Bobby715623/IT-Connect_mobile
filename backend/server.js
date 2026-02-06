require('dotenv').config();
const express = require('express')
const app = express()
const morgan = require('morgan')
const cor = require('cors')
const startCronJob = require('./Controller/Cronjob')
const { readdirSync, readdir } = require('fs')
const bodyParse = require('body-parser')
app.use(morgan('dev'))
app.use(cor())
app.use(bodyParse.json({ limit:'10mb'}))
readdirSync('./routers').map((r)=> app.use('/api',require('./routers/'+r)))
startCronJob();
app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on port 3000');
});

app.use(express.json());
app.use('/auth', require('./routers/User'));//มอสเพิ่ม
app.use('/uploads', express.static('uploads'));//มอสเพิ่ม