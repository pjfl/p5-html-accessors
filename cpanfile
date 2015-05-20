requires "HTML::GenerateUtil" => "1.20";
requires "HTML::Tagset" => "3.20";
requires "perl" => "5.01";

on 'build' => sub {
  requires "Module::Build" => "0.4004";
  requires "Test::Requires" => "0.06";
  requires "version" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};
