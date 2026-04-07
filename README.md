```
     _    _ _
    / \  | (_) __ _ ___
   / _ \ | | |/ _` / __|
  / ___ \| | | (_| \__ \
 /_/   \_\_|_|\__,_|___/
```

# Introduction

The set of alternative names of commands in the style of Assembler commands —
abbreviations or other maximally possible short names.

# Commands

<table>
  <thead>
    <tr>
      <th>Command</th>
      <th>Parameters</th>
      <th>Description</th>
      <th>Example</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="4" align="center">Apache</td>
    </tr>
    <tr>
      <td>eap</td>
      <td>-</td>
      <td>Stop</td>
      <td>eap</td>
    </tr>
    <tr>
      <td>ear</td>
      <td>-</td>
      <td>Restart</td>
      <td>ear</td>
    </tr>
    <tr>
      <td>eas</td>
      <td>-</td>
      <td>Start</td>
      <td>eas</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Composer</td>
    </tr>
    <tr>
      <td>eci</td>
      <td>[any]</td>
      <td>Install</td>
      <td>eci --no-dev</td>
    </tr>
    <tr>
      <td>ecp</td>
      <td><i>See <a href="https://getcomposer.org/doc/03-cli.md#update-u-upgrade">here</a></i></td>
      <td>Get the latest versions of packages without packages for development</td>
      <td>ecp --no-progress</td>
    </tr>
    <tr>
      <td>ecr</td>
      <td>Package name</td>
      <td>Add package</td>
      <td>ecr&nbsp;ohorbatiuk/d8:^0.14</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Docker</td>
    </tr>
    <tr>
      <td>edrd</td>
      <td>-</td>
      <td>Deactivate containers</td>
      <td>edrd</td>
    </tr>
    <tr>
      <td>edre</td>
      <td>
        <ul>
          <li>Container name</li>
          <li>CLI command</li>
        </ul>
      </td>
      <td>Connect to a container or execute any command</td>
      <td>edre myproject_web pwd</td>
    </tr>
    <tr>
      <td>edru</td>
      <td>-</td>
      <td>Activate containers</td>
      <td>edru -f compose.local.yml</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Drupal</td>
    </tr>
    <tr>
      <td>edlu</td>
      <td>
        <ul>
          <li>URL prefix</li>
          <li>Extension name in URL</li>
          <li>URL suffix</li>
        </ul>
      </td>
      <td>Update extension</td>
      <td>edlu https://ftp.drupal.org/files/projects/ standwithukraine -7.x-2.3.tar.gz</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Drush</td>
    </tr>
    <tr>
      <td>edscd</td>
      <td><i>See <a href="https://drushcommands.com/drush-8x/sql/sql-drop">here</a></i></td>
      <td>Drop all tables in a given database</td>
      <td>edscd --database=drupal</td>
    </tr>
    <tr>
      <td>edscl</td>
      <td><i>See <a href="https://drushcommands.com/drush-8x/watchdog/watchdog-delete">here</a></i></td>
      <td>Delete watchdog messages</td>
      <td>edscl --type=cron</td>
    </tr>
    <tr>
      <td><a href="https://drushcommands.com/drush-8x/core/core-cron">edsn</a></td>
      <td>-</td>
      <td>Run cron</td>
      <td>edsn</td>
    </tr>
    <tr>
      <td>edsf</td>
      <td>Module name</td>
      <td>Update feature</td>
      <td>edsf mymodule_blocks</td>
    </tr>
    <tr>
      <td>edsl</td>
      <td>User ID</td>
      <td>Generate a one time login link for the user account</td>
      <td>edsl 10</td>
    </tr>
    <tr>
      <td>ei</td>
      <td rowspan="2">Module or theme name(s)</td>
      <td rowspan="2">Install extension(s)</td>
      <td>ei config2php</td>
    </tr>
    <tr>
      <td>edsmi</td>
      <td>edsmi config2php</td>
    </tr>
    <tr>
      <td>edsmu</td>
      <td>Module name(s)</td>
      <td>Uninstall module(s)</td>
      <td>edsmu ban</td>
    </tr>
    <tr>
      <td>edsq</td>
      <td><i>See <a href="https://drushcommands.com/drush-8x/core/queue-list">here</a></i></td>
      <td>Returns a list of all defined queues</td>
      <td>edsq --format=list</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Git</td>
    </tr>
    <tr>
      <td>ega</td>
      <td><i>See <a href="https://git-scm.com/docs/git-add">here</a></i></td>
      <td>Add file contents to the index</td>
      <td>ega index.php</td>
    </tr>
    <tr>
      <td>egbm</td>
      <td colspan="3">Deprecated! Use <i>egm</i> instead.</td>
    </tr>
    <tr>
      <td><a href="https://git-scm.com/docs/git-switch">egbs</a></td>
      <td>Branch name</td>
      <td>Switching to a specified or previous branch.</td>
      <td>egbs main</td>
    </tr>
    <tr>
      <td>egc</td>
      <td>
        <ul>
          <li>Repository URL (optional)</li>
          <li>Folder name (optional)</li>
        </ul>
      </td>
      <td>Re-clone the repository when the current folder contains the repository. Otherwise, cloning a repository that is defined in a parameter.</td>
      <td>egc https://github.com/ohorbatiuk/alias.git alias</td>
    </tr>
    <tr>
      <td>egm</td>
      <td>—</td>
      <td>Switch to the main branch.</td>
      <td>egm</td>
    </tr>
    <tr>
      <td><a href="https://git-scm.com/docs/git-apply">egp</a></td>
      <td>Filename</td>
      <td>Apply a patch</td>
      <td>egp core.patch</td>
    </tr>
    <tr>
      <td>egrv</td>
      <td>Commit hash(es)</td>
      <td>Revert some existing commit(s)</td>
      <td>egrv 43e8e72</td>
    </tr>
    <tr>
      <td>egs</td>
      <td>-</td>
      <td>Stash the changes in a dirty working directory away</td>
      <td>egs</td>
    </tr>
    <tr>
      <td>egsa</td>
      <td>-</td>
      <td>Apply a single stashed state on top of the current working tree state</td>
      <td>egsa</td>
    </tr>
    <tr>
      <td>egsm</td>
      <td>-</td>
      <td>Add Drupal core as a submodule</td>
      <td>egsm</td>
    </tr>
    <tr>
      <td>egsma</td>
      <td>Module name</td>
      <td>Add a Drupal module as a submodule</td>
      <td>egsma mymodule_blocks</td>
    </tr>
    <tr>
      <td>egsmu</td>
      <td>-</td>
      <td>Update submodules</td>
      <td>egsmu</td>
    </tr>
    <tr>
      <td colspan="4" align="center">MySQL</td>
    </tr>
    <tr>
      <td>emr</td>
      <td>
        <ul>
          <li>Database name (optional)</li>
          <li>SQL-file (optional)</li>
        </ul>
      </td>
      <td>Load database from file or just delete all data and structure if the file is not specified</td>
      <td>emr mydatabase dump.sql</td>
    </tr>
    <tr>
      <td colspan="4" align="center">Operating system</td>
    </tr>
    <tr>
      <td>esc</td>
      <td>-</td>
      <td>Edit commands file</td>
      <td>esc</td>
    </tr>
    <tr>
      <td>escf</td>
      <td>Phrase</td>
      <td>Search a phrase in the commands file</td>
      <td>escf edit</td>
    </tr>
    <tr>
      <td>esh</td>
      <td>-</td>
      <td>Edit hosts file</td>
      <td>esh</td>
    </tr>
    <tr>
      <td>esp</td>
      <td>-</td>
      <td>Set the webserver user as the owner of the Drupal default files directory</td>
      <td>esp</td>
    </tr>
    <tr>
      <td colspan="4" align="center">platform.sh</td>
    </tr>
    <tr>
      <td>epsh</td>
      <td>Filename without extension</td>
      <td>Creating dump of database</td>
      <td>epsh master</td>
    </tr>
  </tbody>
</table>

# Projects

**projects.yml**

```yaml
git:
  user: <git_username>
  mail: <git_email>

<project_name>:
  info:
    title: <project_title>
  local:
    directory: <path>
    database: <local_database_name>
  remote:
    host: <ip_or_domain_name_for_remote_mysql_server_host>
    user: <remote_database_username>
    password: <remote_database_password>
    database: <remote_database_name>
  [dev|live]:
    branch: <git_branch_name>
    ssh:
      host: <ip_or_domain_name_for_remote_ssh_host>
      port: <port_for_remote_ssh_host>
      user: <remote_ssh_username>
      directory: <path>
  docker: <web_server_container_name>
  docker_db: <databases_server_container_name>
  drush:
    uri: <domain_from_multisite_environment>
```
