import { readFileSync, existsSync, writeFileSync } from "fs";
import { resolve } from "path";
import * as admin from "firebase-admin";
export const CREDENTIALS={admin:{email:"admin@uod.edu.ly",password:"Admin@123456"},student:{email:"ahmed.ali@uod.edu.ly",password:"Student@123"},faculty:{email:"layla.hassan@uod.edu.ly",password:"Faculty@123"}};