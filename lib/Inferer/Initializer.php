<?php

namespace Inferer;

trait Initializer
{
  private function defaults()
  {
    return $this->defaults = array();
  }

  private function initializePublicProperties(array $args = array())
  {
    $this->args = array_merge($this->defaults(), $args);
    foreach ($this->args as $public_property => $value) {
      $this->$public_property = $value;
    }
  }
}

?>