<h3>Project description</h3>
<p>A database for classical instrumental music pieces. Each piece has a composer (sometimes multiple), an assumed instrument for performance (sometimes multiple), key, form ("suite", "mazurka", etc.), tempo ("largo", "allegro", etc.), and style ("romanticism", "impressionism", etc.). The number of instruments used in a piece can exceed 1. One pair (TempoMinBPM, TempoMaxBPM) can correspond to multiple tempos. <a href="ERM.png">ERM</a> and <a href="PDM.png">PDM</a> schemes.</p>



<h4>Table definitions</h4>
<p>PostgreSQL 14.5 (Ubuntu 14.5-0ubuntu0.22.04.1) was used as the DBMS for the project. Table and index definitions are provided in the <code><a href="ddl.sql">ddl.sql</a></code> file.</p> 

<h4>Test data</h4>
<p>A script for adding test data is provided in the <code><a href="insert.sql">insert.sql</a></code> file.</p>

<h4>Data retrieval queries</h4>
<p>Data retrieval queries and auxiliary views are provided in the <code><a href="select.sql">select.sql</a></code> file.</p>

<h4>Data modification queries</h4> <p>Data modification queries, stored procedures, and triggers are provided in the <code><a href="update.sql">update.sql</a></code> file.</p>