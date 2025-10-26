// Install dependencies first: npm install @supabase/supabase-js dotenv pg
import { createClient } from '@supabase/supabase-js';
import pg from 'pg';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('❌ Please set SUPABASE_URL and SUPABASE_SERVICE_KEY in .env file');
  process.exit(1);
}

// Extract database connection details from Supabase URL
const projectRef = SUPABASE_URL.match(/https:\/\/([^.]+)\.supabase\.co/)?.[1];
if (!projectRef) {
  console.error('❌ Invalid Supabase URL format');
  process.exit(1);
}

// PostgreSQL connection config
// You'll need to get the direct database URL from Supabase Dashboard > Settings > Database
const DB_CONFIG = {
  host: `db.${projectRef}.supabase.co`,
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: process.env.DB_PASSWORD, // You need to add this to .env
  ssl: { rejectUnauthorized: false }
};

// Create organized folder structure
const outputDir = path.join(__dirname, 'supabase_export');
const dirs = {
  schemas: path.join(outputDir, 'schemas'),
  rls: path.join(outputDir, 'rls_policies'),
  triggers: path.join(outputDir, 'triggers'),
  functions: path.join(outputDir, 'functions'),
  views: path.join(outputDir, 'views'),
  complete: path.join(outputDir, 'complete_schema'),
  data: path.join(outputDir, 'data'),
  dataComplete: path.join(outputDir, 'data', 'complete')
};

// Create all directories
Object.values(dirs).forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

function saveSqlFile(subDir, filename, content) {
  const filePath = path.join(subDir, filename);
  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`✓ Saved: ${filename}`);
}

async function executeQuery(client, query) {
  try {
    const result = await client.query(query);
    return result.rows;
  } catch (error) {
    console.error('Query error:', error.message);
    return [];
  }
}

// Export table schemas
async function exportTableSchemas(client) {
  console.log('\n📋 Exporting table schemas...');
  
  const query = `
    SELECT 
      t.table_name,
      array_agg(
        c.column_name || ' ' || 
        c.data_type || 
        CASE WHEN c.character_maximum_length IS NOT NULL 
          THEN '(' || c.character_maximum_length || ')' 
          ELSE '' END ||
        CASE WHEN c.is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
        CASE WHEN c.column_default IS NOT NULL 
          THEN ' DEFAULT ' || c.column_default 
          ELSE '' END
        ORDER BY c.ordinal_position
      ) as columns
    FROM information_schema.tables t
    JOIN information_schema.columns c ON t.table_name = c.table_name 
      AND t.table_schema = c.table_schema
    WHERE t.table_schema = 'public' 
      AND t.table_type = 'BASE TABLE'
    GROUP BY t.table_name
    ORDER BY t.table_name;
  `;

  const tables = await executeQuery(client, query);
  let completeSchema = `-- Complete Database Schema\n`;
  completeSchema += `-- Generated: ${new Date().toISOString()}\n`;
  completeSchema += `-- Database: ${DB_CONFIG.host}\n\n`;
  
  for (const table of tables) {
    let sql = `-- Table: ${table.table_name}\n`;
    sql += `-- Generated: ${new Date().toISOString()}\n\n`;
    sql += `CREATE TABLE IF NOT EXISTS public.${table.table_name} (\n`;
    sql += `  ${table.columns.join(',\n  ')}\n`;
    sql += `);\n\n`;
    
    // Get constraints
    const constraintsQuery = `
      SELECT
        tc.constraint_name,
        tc.constraint_type,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
      FROM information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      LEFT JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
      WHERE tc.table_schema = 'public'
        AND tc.table_name = '${table.table_name}';
    `;
    
    const constraints = await executeQuery(client, constraintsQuery);
    
    if (constraints.length > 0) {
      sql += `-- Constraints\n`;
      constraints.forEach(constraint => {
        if (constraint.constraint_type === 'PRIMARY KEY') {
          sql += `ALTER TABLE public.${table.table_name} ADD CONSTRAINT ${constraint.constraint_name} PRIMARY KEY (${constraint.column_name});\n`;
        } else if (constraint.constraint_type === 'FOREIGN KEY') {
          sql += `ALTER TABLE public.${table.table_name} ADD CONSTRAINT ${constraint.constraint_name} FOREIGN KEY (${constraint.column_name}) REFERENCES ${constraint.foreign_table_name}(${constraint.foreign_column_name});\n`;
        } else if (constraint.constraint_type === 'UNIQUE') {
          sql += `ALTER TABLE public.${table.table_name} ADD CONSTRAINT ${constraint.constraint_name} UNIQUE (${constraint.column_name});\n`;
        }
      });
      sql += '\n';
    }
    
    completeSchema += sql;
    saveSqlFile(dirs.schemas, `${table.table_name}.sql`, sql);
  }
  
  // Save complete schema
  saveSqlFile(dirs.complete, 'all_tables.sql', completeSchema);
  console.log(`✓ Exported ${tables.length} table schemas`);
}

// Export RLS policies
async function exportRLSPolicies(client) {
  console.log('\n🔒 Exporting RLS policies...');
  
  const query = `
    SELECT 
      schemaname,
      tablename,
      policyname,
      permissive,
      roles,
      cmd,
      qual,
      with_check
    FROM pg_policies
    WHERE schemaname = 'public'
    ORDER BY tablename, policyname;
  `;

  const policies = await executeQuery(client, query);
  let completeRLS = `-- Complete RLS Policies\n`;
  completeRLS += `-- Generated: ${new Date().toISOString()}\n\n`;
  
  if (policies.length > 0) {
    const grouped = {};
    
    policies.forEach(policy => {
      if (!grouped[policy.tablename]) {
        grouped[policy.tablename] = [];
      }
      grouped[policy.tablename].push(policy);
    });

    for (const [tableName, tablePolicies] of Object.entries(grouped)) {
      let sql = `-- RLS Policies for: ${tableName}\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n\n`;
      sql += `ALTER TABLE public.${tableName} ENABLE ROW LEVEL SECURITY;\n\n`;

      tablePolicies.forEach(policy => {
        sql += `DROP POLICY IF EXISTS "${policy.policyname}" ON public.${tableName};\n`;
        sql += `CREATE POLICY "${policy.policyname}"\n`;
        sql += `  ON public.${tableName}\n`;
        sql += `  AS ${policy.permissive.toUpperCase()}\n`;
        sql += `  FOR ${policy.cmd}\n`;
        const roles = Array.isArray(policy.roles) ? policy.roles.join(', ') : policy.roles;
        sql += `  TO ${roles}\n`;
        
        if (policy.qual) {
          sql += `  USING (${policy.qual})\n`;
        }
        if (policy.with_check) {
          sql += `  WITH CHECK (${policy.with_check})\n`;
        }
        sql += `;\n\n`;
      });

      completeRLS += sql;
      saveSqlFile(dirs.rls, `${tableName}.sql`, sql);
    }
    
    saveSqlFile(dirs.complete, 'all_rls_policies.sql', completeRLS);
    console.log(`✓ Exported RLS policies for ${Object.keys(grouped).length} tables`);
  } else {
    console.log('ℹ No RLS policies found');
  }
}

// Export triggers
async function exportTriggers(client) {
  console.log('\n⚡ Exporting triggers...');
  
  const query = `
    SELECT 
      n.nspname as schema_name,
      c.relname as table_name,
      t.tgname as trigger_name,
      pg_get_triggerdef(t.oid) as trigger_definition
    FROM pg_trigger t
    JOIN pg_class c ON t.tgrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'public'
      AND NOT t.tgisinternal
    ORDER BY c.relname, t.tgname;
  `;

  const triggers = await executeQuery(client, query);
  let completeTriggers = `-- Complete Triggers\n`;
  completeTriggers += `-- Generated: ${new Date().toISOString()}\n\n`;
  
  if (triggers.length > 0) {
    const grouped = {};
    
    triggers.forEach(trigger => {
      if (!grouped[trigger.table_name]) {
        grouped[trigger.table_name] = [];
      }
      grouped[trigger.table_name].push(trigger);
    });

    for (const [tableName, tableTriggers] of Object.entries(grouped)) {
      let sql = `-- Triggers for: ${tableName}\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n\n`;

      tableTriggers.forEach(trigger => {
        sql += `${trigger.trigger_definition};\n\n`;
      });

      completeTriggers += sql;
      saveSqlFile(dirs.triggers, `${tableName}.sql`, sql);
    }
    
    saveSqlFile(dirs.complete, 'all_triggers.sql', completeTriggers);
    console.log(`✓ Exported triggers for ${Object.keys(grouped).length} tables`);
  } else {
    console.log('ℹ No triggers found');
  }
}

// Export functions
async function exportFunctions(client) {
  console.log('\n⚙️  Exporting functions...');
  
  const query = `
    SELECT 
      p.proname as function_name,
      pg_get_functiondef(p.oid) as function_definition
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    ORDER BY p.proname;
  `;

  const functions = await executeQuery(client, query);
  let completeFunctions = `-- Complete Functions\n`;
  completeFunctions += `-- Generated: ${new Date().toISOString()}\n\n`;
  
  if (functions.length > 0) {
    functions.forEach(func => {
      let sql = `-- Function: ${func.function_name}\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n\n`;
      sql += `${func.function_definition};\n\n`;
      
      completeFunctions += sql;
      saveSqlFile(dirs.functions, `${func.function_name}.sql`, sql);
    });
    
    saveSqlFile(dirs.complete, 'all_functions.sql', completeFunctions);
    console.log(`✓ Exported ${functions.length} functions`);
  } else {
    console.log('ℹ No functions found');
  }
}

// Export views
async function exportViews(client) {
  console.log('\n👁️  Exporting views...');
  
  const query = `
    SELECT 
      table_name as view_name,
      view_definition
    FROM information_schema.views
    WHERE table_schema = 'public'
    ORDER BY table_name;
  `;

  const views = await executeQuery(client, query);
  let completeViews = `-- Complete Views\n`;
  completeViews += `-- Generated: ${new Date().toISOString()}\n\n`;
  
  if (views.length > 0) {
    views.forEach(view => {
      let sql = `-- View: ${view.view_name}\n`;
      sql += `-- Generated: ${new Date().toISOString()}\n\n`;
      sql += `CREATE OR REPLACE VIEW public.${view.view_name} AS\n`;
      sql += `${view.view_definition};\n\n`;
      
      completeViews += sql;
      saveSqlFile(dirs.views, `${view.view_name}.sql`, sql);
    });
    
    saveSqlFile(dirs.complete, 'all_views.sql', completeViews);
    console.log(`✓ Exported ${views.length} views`);
  } else {
    console.log('ℹ No views found');
  }
}

// Main export function
async function exportAll() {
  console.log('🚀 Starting Supabase schema export...');
  console.log(`📁 Output directory: ${outputDir}\n`);
  console.log('📂 Folder structure:');
  console.log('   ├── schemas/          (Individual table schemas)');
  console.log('   ├── rls_policies/     (Individual RLS policies)');
  console.log('   ├── triggers/         (Individual triggers)');
  console.log('   ├── functions/        (Individual functions)');
  console.log('   ├── views/            (Individual views)');
  console.log('   └── complete_schema/  (All-in-one files)\n');
  
  const client = new pg.Client(DB_CONFIG);
  
  try {
    console.log('🔌 Connecting to database...');
    await client.connect();
    console.log('✓ Connected successfully\n');
    
    await exportTableSchemas(client);
    await exportRLSPolicies(client);
    await exportTriggers(client);
    await exportFunctions(client);
    await exportViews(client);
    
    // Create a master file with everything
    console.log('\n📝 Creating master schema file...');
    const masterFile = `-- Complete Database Export
-- Generated: ${new Date().toISOString()}
-- Database: ${DB_CONFIG.host}

-- This file contains all database objects in the correct order for recreation

-- ============================================================
-- TABLES
-- ============================================================

-- See: complete_schema/all_tables.sql for table definitions

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- See: complete_schema/all_functions.sql for function definitions

-- ============================================================
-- VIEWS
-- ============================================================

-- See: complete_schema/all_views.sql for view definitions

-- ============================================================
-- TRIGGERS
-- ============================================================

-- See: complete_schema/all_triggers.sql for trigger definitions

-- ============================================================
-- RLS POLICIES
-- ============================================================

-- See: complete_schema/all_rls_policies.sql for RLS policy definitions

-- ============================================================
-- Import Order (for restoring the database):
-- ============================================================
-- 1. all_tables.sql
-- 2. all_functions.sql
-- 3. all_views.sql
-- 4. all_triggers.sql
-- 5. all_rls_policies.sql
`;
    
    saveSqlFile(dirs.complete, 'README.sql', masterFile);
    
    console.log(`\n✅ Export complete!`);
    console.log(`\n📊 Export Summary:`);
    console.log(`   Location: ${outputDir}`);
    console.log(`   Individual files: Check subfolders for granular control`);
    console.log(`   Complete schemas: Check complete_schema/ for all-in-one files`);
  } catch (error) {
    console.error('\n❌ Export failed:', error.message);
    if (error.message.includes('password authentication failed')) {
      console.log('\n💡 Make sure you have added DB_PASSWORD to your .env file');
      console.log('Get it from: Supabase Dashboard > Settings > Database > Connection string');
    }
  } finally {
    await client.end();
  }
}

// Run the export
exportAll();